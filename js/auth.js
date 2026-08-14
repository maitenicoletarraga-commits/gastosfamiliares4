// =========================================================
// auth.js - Registro, inicio de sesión y control de sesión
// =========================================================

async function registrar(email, password) {
  const { data, error } = await supabase.auth.signUp({ email, password });
  return { data, error };
}

async function iniciarSesion(email, password) {
  const { data, error } = await supabase.auth.signInWithPassword({ email, password });
  return { data, error };
}

async function cerrarSesion() {
  await supabase.auth.signOut();
  window.location.href = "login.html";
}

// Protege index.html: si no hay sesión activa, redirige al login.
// login.html no carga este archivo, así que no se aplica ahí.
supabase.auth.onAuthStateChange((event, session) => {
  const enLogin = window.location.pathname.endsWith("login.html");
  if (!session && !enLogin) window.location.href = "login.html";
});
