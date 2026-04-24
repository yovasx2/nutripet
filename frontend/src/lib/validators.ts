export function isValidEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

export function isValidPassword(password: string): boolean {
  return password.length >= 8;
}

export function validateLogin(email: string, password: string): string | null {
  if (!email.trim()) return "El correo electrónico es obligatorio";
  if (!isValidEmail(email)) return "El correo electrónico no es válido";
  if (!password) return "La contraseña es obligatoria";
  return null;
}

export function validateRegister(
  email: string,
  password: string,
  passwordConfirmation: string,
  name: string
): string | null {
  if (!name.trim()) return "El nombre es obligatorio";
  if (!email.trim()) return "El correo electrónico es obligatorio";
  if (!isValidEmail(email)) return "El correo electrónico no es válido";
  if (!password) return "La contraseña es obligatoria";
  if (password.length < 8) return "La contraseña debe tener al menos 8 caracteres";
  if (password !== passwordConfirmation) return "Las contraseñas no coinciden";
  return null;
}

export function validateForgotPassword(email: string): string | null {
  if (!email.trim()) return "El correo electrónico es obligatorio";
  if (!isValidEmail(email)) return "El correo electrónico no es válido";
  return null;
}

export function validateResetPassword(
  password: string,
  passwordConfirmation: string
): string | null {
  if (!password) return "La contraseña es obligatoria";
  if (password.length < 8) return "La contraseña debe tener al menos 8 caracteres";
  if (password !== passwordConfirmation) return "Las contraseñas no coinciden";
  return null;
}
