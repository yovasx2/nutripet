import { useEffect, useRef } from 'react';
import * as THREE from 'three';

interface MolData {
  type: string; color: number; glow: number;
  label: string; sublabel: string;
  pos: [number, number, number]; scale: number;
}

const MOLECULES: MolData[] = [
  { type: 'protein', color: 0x8b9a7f, glow: 0xa8b89a, label: 'Proteína', sublabel: 'Construcción muscular', pos: [-3, 1.2, 0], scale: 1 },
  { type: 'omega3', color: 0xc25e44, glow: 0xd97b5a, label: 'Omega-3', sublabel: 'EPA/DHA · Antiinflamatorio', pos: [3, 0.8, -1], scale: 0.9 },
  { type: 'amino', color: 0x7a8f6d, glow: 0x95a985, label: 'Aminoácidos', sublabel: 'Triptófano · Lisina', pos: [-2.5, -1.8, 1], scale: 0.85 },
  { type: 'zinc', color: 0xb8a88a, glow: 0xcdc0a8, label: 'Zinc', sublabel: 'Soporte inmune', pos: [2.5, -1.5, 0.5], scale: 0.8 },
  { type: 'vitE', color: 0xc25e44, glow: 0xe0785a, label: 'Vitamina E', sublabel: 'Antioxidante · Tocoferol', pos: [0.5, 2.2, -0.5], scale: 1.05 },
  { type: 'iron', color: 0x6b7d5e, glow: 0x8b9a7f, label: 'Hierro', sublabel: 'Grupo Hemo · Oxígeno', pos: [0, -0.3, 1.2], scale: 0.75 },
];

function buildMolecule(type: string, color: number, glowColor: number): THREE.Group {
  const g = new THREE.Group();

  const atomMat = new THREE.MeshLambertMaterial({ color });
  const bondMat = new THREE.MeshLambertMaterial({ color: 0xc8c0b4 });
  const glowMat = new THREE.MeshBasicMaterial({ color: glowColor, transparent: true, opacity: 0.06, depthWrite: false });

  const addAtom = (x: number, y: number, z: number, r: number) => {
    const m = new THREE.Mesh(new THREE.SphereGeometry(r, 14, 14), atomMat);
    m.position.set(x, y, z);
    g.add(m);
    const halo = new THREE.Mesh(new THREE.SphereGeometry(r * 2.2, 10, 10), glowMat.clone());
    halo.position.set(x, y, z);
    g.add(halo);
  };

  const addBond = (x1: number, y1: number, z1: number, x2: number, y2: number, z2: number, thick = 0.05) => {
    const dx = x2 - x1, dy = y2 - y1, dz = z2 - z1;
    const len = Math.sqrt(dx * dx + dy * dy + dz * dz);
    const geo = new THREE.CylinderGeometry(thick, thick, len, 6);
    const mesh = new THREE.Mesh(geo, bondMat);
    mesh.position.set((x1 + x2) / 2, (y1 + y2) / 2, (z1 + z2) / 2);
    mesh.lookAt(x2, y2, z2);
    mesh.rotateX(Math.PI / 2);
    g.add(mesh);
  };

  if (type === 'protein') {
    const rings = [[0, 0], [1.0, 0.55], [2.0, 0], [1.0, -0.55]];
    rings.forEach(([cx, cy]) => {
      const r = 0.45;
      for (let i = 0; i < 6; i++) {
        const a = (Math.PI / 3) * i;
        addAtom(cx + Math.cos(a) * r, cy + Math.sin(a) * r, 0, 0.12);
      }
      for (let i = 0; i < 6; i++) {
        const a1 = (Math.PI / 3) * i, a2 = (Math.PI / 3) * ((i + 1) % 6);
        addBond(cx + Math.cos(a1) * r, cy + Math.sin(a1) * r, 0, cx + Math.cos(a2) * r, cy + Math.sin(a2) * r, 0);
      }
    });
  } else if (type === 'omega3') {
    const pts: [number, number, number][] = [];
    for (let i = 0; i < 7; i++) pts.push([i * 0.5 - 1.5, (i % 2 === 0 ? 0.25 : -0.25), 0]);
    pts.forEach(p => addAtom(p[0], p[1], p[2], 0.11));
    for (let i = 0; i < pts.length - 1; i++) addBond(pts[i][0], pts[i][1], pts[i][2], pts[i + 1][0], pts[i + 1][1], pts[i + 1][2], 0.04);
  } else if (type === 'amino') {
    for (let i = 0; i < 10; i++) {
      const a = i * 0.7;
      addAtom(Math.cos(a) * 0.5, (i - 5) * 0.22, Math.sin(a) * 0.5, 0.1);
      if (i > 0) {
        const pa = (i - 1) * 0.7;
        addBond(Math.cos(pa) * 0.5, (i - 6) * 0.22, Math.sin(pa) * 0.5, Math.cos(a) * 0.5, (i - 5) * 0.22, Math.sin(a) * 0.5, 0.04);
      }
    }
  } else if (type === 'zinc') {
    const r6 = 0.5;
    for (let i = 0; i < 6; i++) {
      const a = (Math.PI / 3) * i - Math.PI / 6;
      addAtom(Math.cos(a) * r6, Math.sin(a) * r6 - 0.1, 0, 0.09);
    }
    for (let i = 0; i < 6; i++) {
      const a1 = (Math.PI / 3) * i - Math.PI / 6, a2 = (Math.PI / 3) * ((i + 1) % 6) - Math.PI / 6;
      addBond(Math.cos(a1) * r6, Math.sin(a1) * r6 - 0.1, 0, Math.cos(a2) * r6, Math.sin(a2) * r6 - 0.1, 0);
    }
    const znMat = new THREE.MeshLambertMaterial({ color: 0xe8dcc8 });
    const zn = new THREE.Mesh(new THREE.SphereGeometry(0.18, 16, 16), znMat);
    g.add(zn);
  } else if (type === 'vitE') {
    const r = 0.55;
    for (let i = 0; i < 6; i++) {
      const a = (Math.PI / 3) * i;
      addAtom(Math.cos(a) * r, Math.sin(a) * r, 0, 0.1);
    }
    for (let i = 0; i < 6; i++) {
      const a1 = (Math.PI / 3) * i, a2 = (Math.PI / 3) * ((i + 1) % 6);
      addBond(Math.cos(a1) * r, Math.sin(a1) * r, 0, Math.cos(a2) * r, Math.sin(a2) * r, 0);
    }
    for (let i = 0; i < 3; i++) addAtom(0.8 + i * 0.35, -0.25 + Math.sin(i) * 0.15, 0, 0.08);
    const ringGeo = new THREE.TorusGeometry(1.0, 0.015, 6, 40);
    const ringMat = new THREE.MeshBasicMaterial({ color: glowColor, transparent: true, opacity: 0.12, depthWrite: false });
    const ring = new THREE.Mesh(ringGeo, ringMat);
    ring.position.set(0.3, 0, 0);
    g.add(ring);
  } else if (type === 'iron') {
    const r = 0.6;
    const c = [[-r, -r], [r, -r], [r, r], [-r, r]];
    c.forEach(p => addAtom(p[0], p[1], 0, 0.1));
    for (let i = 0; i < 4; i++) addBond(c[i][0], c[i][1], 0, c[(i + 1) % 4][0], c[(i + 1) % 4][1], 0);
    c.forEach(p => {
      const m = new THREE.Mesh(new THREE.SphereGeometry(0.07, 10, 10), new THREE.MeshLambertMaterial({ color: 0x9ab08a }));
      m.position.set(p[0] * 0.5, p[1] * 0.5, 0);
      g.add(m);
    });
    const fe = new THREE.Mesh(new THREE.SphereGeometry(0.18, 16, 16), new THREE.MeshLambertMaterial({ color: 0xc25e44 }));
    g.add(fe);
    addBond(-r * 0.5, -r * 0.5, 0, r * 0.5, r * 0.5, 0, 0.025);
    addBond(r * 0.5, -r * 0.5, 0, -r * 0.5, r * 0.5, 0, 0.025);
  }

  return g;
}

export default function MoleculesCanvas() {
  const containerRef = useRef<HTMLDivElement>(null);
  const frameRef = useRef<number>(0);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const scene = new THREE.Scene();
    scene.background = new THREE.Color(0xfaf8f3);

    const w = container.clientWidth;
    const h = container.clientHeight;

    const camera = new THREE.PerspectiveCamera(45, w / h, 0.1, 100);
    camera.position.set(0, 0, 9);

    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(w, h);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    container.appendChild(renderer.domElement);

    scene.add(new THREE.AmbientLight(0xfff8f0, 0.7));
    const dl = new THREE.DirectionalLight(0xfff0e0, 1.0);
    dl.position.set(4, 6, 5);
    scene.add(dl);
    const dl2 = new THREE.DirectionalLight(0xe8ddd0, 0.5);
    dl2.position.set(-4, -2, 3);
    scene.add(dl2);

    // Particles
    const pCount = 50;
    const pGeo = new THREE.BufferGeometry();
    const pArr = new Float32Array(pCount * 3);
    for (let i = 0; i < pCount; i++) {
      pArr[i * 3] = (Math.random() - 0.5) * 12;
      pArr[i * 3 + 1] = (Math.random() - 0.5) * 8;
      pArr[i * 3 + 2] = (Math.random() - 0.5) * 4;
    }
    pGeo.setAttribute('position', new THREE.BufferAttribute(pArr, 3));
    const particles = new THREE.Points(pGeo, new THREE.PointsMaterial({ color: 0xc8c0b4, size: 0.035, transparent: true, opacity: 0.4, sizeAttenuation: true }));
    scene.add(particles);

    // Molecules
    const molGroups: THREE.Group[] = [];
    const initPos: THREE.Vector3[] = [];
    const rotSpd: THREE.Vector3[] = [];

    MOLECULES.forEach(d => {
      const mol = buildMolecule(d.type, d.color, d.glow);
      mol.position.set(d.pos[0], d.pos[1], d.pos[2]);
      mol.scale.setScalar(d.scale);
      scene.add(mol);
      molGroups.push(mol);
      initPos.push(new THREE.Vector3(d.pos[0], d.pos[1], d.pos[2]));
      rotSpd.push(new THREE.Vector3((Math.random() - 0.5) * 0.004, (Math.random() - 0.5) * 0.006, (Math.random() - 0.5) * 0.002));
    });

    const clock = new THREE.Clock();

    const animate = () => {
      frameRef.current = requestAnimationFrame(animate);
      const t = clock.getElapsedTime();

      molGroups.forEach((mol, i) => {
        const ip = initPos[i];
        mol.position.y = ip.y + Math.sin(t * 0.5 + i * 1.2) * 0.2;
        mol.position.x = ip.x + Math.sin(t * 0.25 + i * 0.6) * 0.12;
        mol.rotation.x += rotSpd[i].x;
        mol.rotation.y += rotSpd[i].y;
      });

      particles.rotation.y = t * 0.015;

      renderer.render(scene, camera);
    };
    animate();

    const onResize = () => {
      const nw = container.clientWidth;
      const nh = container.clientHeight;
      camera.aspect = nw / nh;
      camera.updateProjectionMatrix();
      renderer.setSize(nw, nh);
    };
    window.addEventListener('resize', onResize);

    return () => {
      cancelAnimationFrame(frameRef.current);
      window.removeEventListener('resize', onResize);
      renderer.dispose();
      if (container.contains(renderer.domElement)) container.removeChild(renderer.domElement);
    };
  }, []);

  return <div ref={containerRef} className="relative w-full" style={{ minHeight: 380 }} />;
}
