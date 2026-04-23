import { useEffect, useRef } from 'react';
import * as THREE from 'three';
import { FontLoader } from 'three/examples/jsm/loaders/FontLoader.js';
import { TextGeometry } from 'three/examples/jsm/geometries/TextGeometry.js';

// All 22 nutrients distributed on a full 3D sphere surface
const NUTRIENTS_3D = [
  // Vitamins ring (equator area)
  { name: 'Vitamina A',     theta: 0.30, phi: 1.50 },
  { name: 'Vitamina D',     theta: 0.90, phi: 1.55 },
  { name: 'Vitamina E',     theta: 1.50, phi: 1.45 },
  { name: 'Vitamina K',     theta: 2.10, phi: 1.60 },
  { name: 'Complejo B',     theta: 2.70, phi: 1.50 },
  { name: 'Folato',         theta: 3.30, phi: 1.55 },
  // Minerals ring (lower band)
  { name: 'Zinc',           theta: 0.60, phi: 2.10 },
  { name: 'Hierro',         theta: 1.20, phi: 2.05 },
  { name: 'Selenio',        theta: 1.80, phi: 2.15 },
  { name: 'Cobre',          theta: 2.40, phi: 2.00 },
  { name: 'Manganeso',      theta: 3.00, phi: 2.10 },
  { name: 'Yodo',           theta: 3.60, phi: 2.05 },
  { name: 'Calcio',         theta: 4.20, phi: 2.15 },
  { name: 'Fosforo',        theta: 4.80, phi: 2.00 },
  // Functional nutrients ring (upper band)
  { name: 'Taurina',        theta: 0.45, phi: 0.95 },
  { name: 'L-Carnitina',    theta: 1.05, phi: 0.90 },
  { name: 'Metionina',      theta: 1.65, phi: 1.00 },
  { name: 'Lisina',         theta: 2.25, phi: 0.85 },
  { name: 'Omega-3',        theta: 2.85, phi: 0.95 },
  { name: 'DHA',            theta: 3.45, phi: 0.88 },
  { name: 'EPA',            theta: 4.05, phi: 0.92 },
];

export default function NutritionalDataGlobe() {
  const containerRef = useRef<HTMLDivElement>(null);
  const frameRef = useRef<number>(0);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const w = container.clientWidth;
    const h = container.clientHeight;

    // Scene (no background = transparent, blends with page)
    const scene = new THREE.Scene();

    // Camera: closer framing to keep all labels within visible bounds
    const camera = new THREE.PerspectiveCamera(45, w / h, 0.1, 1000);
    camera.position.set(0, 0.5, 13);
    camera.lookAt(0, 0, 0);

    // Renderer — transparent to blend with page background
    const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
    renderer.setClearColor(0x000000, 0);
    renderer.setSize(w, h);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    container.appendChild(renderer.domElement);

    // Lights
    scene.add(new THREE.AmbientLight(0xffffff, 0.7));
    const dl1 = new THREE.DirectionalLight(0xfff5e8, 0.9);
    dl1.position.set(8, 10, 8);
    scene.add(dl1);
    const dl2 = new THREE.DirectionalLight(0xe8e0d4, 0.4);
    dl2.position.set(-8, -4, 5);
    scene.add(dl2);

    // Main group
    const mainGroup = new THREE.Group();
    scene.add(mainGroup);

    // Wireframe sphere — tighter to keep labels well inside container bounds
    const sphereR = 3.0;
    const sphere = new THREE.Mesh(
      new THREE.IcosahedronGeometry(sphereR, 3),
      new THREE.MeshBasicMaterial({ color: 0x8b9a7f, wireframe: true, transparent: true, opacity: 0.22 })
    );
    mainGroup.add(sphere);

    // Inner subtle glow sphere
    const innerSphere = new THREE.Mesh(
      new THREE.SphereGeometry(sphereR * 0.9, 20, 20),
      new THREE.MeshBasicMaterial({ color: 0xe8dcc8, transparent: true, opacity: 0.04, depthWrite: false })
    );
    mainGroup.add(innerSphere);

    const textMeshes: THREE.Mesh[] = [];

    // Load font & place nutrients on 3D sphere surface
    const fontLoader = new FontLoader();
    fontLoader.load(
      'https://threejs.org/examples/fonts/helvetiker_regular.typeface.json',
      (font) => {
        const textRadius = sphereR + 0.9;
        const textSize = 0.38;

        NUTRIENTS_3D.forEach((n, i) => {
          // Convert spherical → cartesian
          const x = textRadius * Math.sin(n.phi) * Math.cos(n.theta);
          const y = textRadius * Math.cos(n.phi);
          const z = textRadius * Math.sin(n.phi) * Math.sin(n.theta);

          const textGeo = new TextGeometry(n.name, {
            font,
            size: textSize,
            depth: 0.06,
          });
          textGeo.computeBoundingBox();
          textGeo.center();

          // Color based on ring (vitamins=olive, minerals=sage, functional=terracotta)
          const isVit = i < 6;
          const isMin = i < 14;
          const color = isVit ? 0x6b7d5e : isMin ? 0x8b9a7f : 0xc25e44;

          const textMat = new THREE.MeshLambertMaterial({ color, transparent: true, opacity: 0.85 });
          const textMesh = new THREE.Mesh(textGeo, textMat);
          textMesh.position.set(x, y, z);
          textMesh.lookAt(camera.position);

          textMesh.userData = {
            baseX: x, baseY: y, baseZ: z,
            theta: n.theta, phi: n.phi,
            textRadius,
            floatOffset: Math.random() * Math.PI * 2,
            floatSpeed: 0.4 + Math.random() * 0.4,
            orbitSpeed: (0.0015 + Math.random() * 0.001) * (i % 2 === 0 ? 1 : -1),
          };

          mainGroup.add(textMesh);
          textMeshes.push(textMesh);
        });
      }
    );

    // Floating particles
    const pCount = 80;
    const pGeo = new THREE.BufferGeometry();
    const pArr = new Float32Array(pCount * 3);
    for (let i = 0; i < pCount; i++) {
      const r = 6 + Math.random() * 5;
      const t = Math.random() * Math.PI * 2;
      const p = Math.random() * Math.PI;
      pArr[i * 3] = r * Math.sin(p) * Math.cos(t);
      pArr[i * 3 + 1] = r * Math.cos(p);
      pArr[i * 3 + 2] = r * Math.sin(p) * Math.sin(t);
    }
    pGeo.setAttribute('position', new THREE.BufferAttribute(pArr, 3));
    const particles = new THREE.Points(
      pGeo,
      new THREE.PointsMaterial({ color: 0xc8c0b4, size: 0.04, transparent: true, opacity: 0.35, sizeAttenuation: true })
    );
    mainGroup.add(particles);

    // Animation
    const clock = new THREE.Clock();

    const animate = () => {
      frameRef.current = requestAnimationFrame(animate);
      const t = clock.getElapsedTime();

      // Slow group rotation
      mainGroup.rotation.y += 0.0008;

      // Each text orbits on its own spherical path + floats
      textMeshes.forEach((mesh) => {
        const ud = mesh.userData;
        if (!ud.baseX) return;

        // Advance theta for orbital motion
        ud.theta += ud.orbitSpeed;

        // Add slight phi wobble for 3D movement
        const phiWobble = Math.sin(t * 0.3 + ud.floatOffset) * 0.12;
        const currentPhi = ud.phi + phiWobble;

        // Recalculate position on sphere surface
        const r = ud.textRadius + Math.sin(t * ud.floatSpeed + ud.floatOffset) * 0.2;
        const nx = r * Math.sin(currentPhi) * Math.cos(ud.theta);
        const ny = r * Math.cos(currentPhi);
        const nz = r * Math.sin(currentPhi) * Math.sin(ud.theta);

        mesh.position.set(nx, ny, nz);
        mesh.lookAt(camera.position);

        if (mesh.material instanceof THREE.MeshLambertMaterial) {
          mesh.material.opacity = 0.6 + Math.sin(t * 1.5 + ud.floatOffset) * 0.25;
        }
      });

      // Gentle particle drift
      particles.rotation.y = t * 0.008;

      renderer.render(scene, camera);
    };

    animate();

    // Resize
    const handleResize = () => {
      const nw = container.clientWidth;
      const nh = container.clientHeight;
      camera.aspect = nw / nh;
      camera.updateProjectionMatrix();
      renderer.setSize(nw, nh);
    };
    window.addEventListener('resize', handleResize);

    return () => {
      cancelAnimationFrame(frameRef.current);
      window.removeEventListener('resize', handleResize);
      renderer.dispose();
      if (container.contains(renderer.domElement)) container.removeChild(renderer.domElement);
    };
  }, []);

  return <div ref={containerRef} className="w-full h-full" />;
}
