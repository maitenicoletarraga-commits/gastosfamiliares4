// =========================================================
// login.js - Lógica del formulario de login.html
// =========================================================

let modoRegistro = false;

const formLogin = document.getElementById("formLogin");
const btnAcceder = document.getElementById("btnAcceder");
const btnCambiarModo = document.getElementById("btnCambiarModo");
const loginSubtitle = document.getElementById("loginSubtitle");

// Si ya hay una sesión activa, no tiene sentido mostrar el login: redirige directo.
supabase.auth.getSession().then(({ data: { session } }) => {
  if (session) window.location.href = "index.html";
});

btnCambiarModo.addEventListener("click", () => {
  modoRegistro = !modoRegistro;
  if (modoRegistro) {
    btnAcceder.textContent = "Crear cuenta";
    btnCambiarModo.textContent = "Ya tengo una cuenta";
    loginSubtitle.textContent = "Crea tu cuenta para empezar";
  } else {
    btnAcceder.textContent = "Iniciar sesión";
    btnCambiarModo.textContent = "Crear una cuenta nueva";
    loginSubtitle.textContent = "Inicia sesión para continuar";
  }
});

formLogin.addEventListener("submit", async (e) => {
  e.preventDefault();

  const email = document.getElementById("email").value.trim();
  const password = document.getElementById("password").value;

  if (modoRegistro) {
    const { data, error } = await registrar(email, password);
    if (error) return mostrarToast("Error al crear la cuenta: " + error.message, "error");

    if (!data.session) {
      mostrarToast("Cuenta creada. Si no accedes, revisa que 'Confirm email' esté desactivado en Supabase.", "error");
      return;
    }
    mostrarToast("Cuenta creada correctamente", "exito");
  } else {
    const { data, error } = await iniciarSesion(email, password);
    if (error) return mostrarToast("Error al iniciar sesión: " + error.message, "error");
    if (!data.session) {
      mostrarToast("No se pudo iniciar sesión: falta confirmar el correo.", "error");
      return;
    }
  }

  window.location.href = "index.html";
});
