# App de Gastos Familiares

Proyecto educativo — Sistemas Informáticos

> **Nota para el profesor:** esta versión del proyecto tiene la Tarea 1 y
> la Tarea 2 **completamente implementadas** (toasts, login, roles y RLS
> activados) — es la versión de referencia / solucionario. La copia que
> se entrega a los estudiantes debe partir sin `js/toast.js`, `js/auth.js`,
> `login.html`, ni `sql/migracion_02_rls_gastos.sql`, y sin RLS activado
> en `gastos` — ellos construyen esas piezas siguiendo las instrucciones
> de este mismo documento, sección "Tarea 2".

## Objetivo del proyecto

Aprender a construir y desplegar una aplicación web real (no local) conectando:

- **Frontend**: HTML, CSS y JavaScript.
- **Backend / Base de datos**: Supabase (Postgres en la nube + almacenamiento de archivos).
- **Control de versiones**: GitHub.
- **Despliegue**: Vercel.

Esta app permite registrar los gastos de una familia, ver un dashboard con
estadísticas y subir una foto familiar. El sistema está diseñado para
**escalar más adelante** con login y roles (papá, mamá, hijo), aunque en
esta primera versión no los incluye.

## Herramientas que debes manejar

- Navegador web (Chrome recomendado).
- Cuenta de correo (para crear cuenta en Supabase y GitHub).
- [Visual Studio Code](https://code.visualstudio.com/).
- Cuenta en [Supabase](https://supabase.com).
- Cuenta en [GitHub](https://github.com).
- Cuenta en [Vercel](https://vercel.com).
- Conocimientos básicos de HTML, CSS y JavaScript.

## Requisitos previos

1. Tener las 4 cuentas creadas (Supabase, GitHub, Vercel — Vercel se puede
   crear con la misma cuenta de GitHub).
2. Tener VS Code instalado.
3. Tener este proyecto descomprimido en tu computadora.

## Verificación previa: Git y sincronización con GitHub

Antes de empezar a trabajar, y también antes de dar por terminada cualquier
sesión, verifica estos puntos. Es muy común tener Git instalado y trabajar
normalmente en VS Code sin que el proyecto esté realmente sincronizado con
GitHub — si no lo revisas, puedes pasar toda la sesión editando código que
nunca llega al repositorio remoto.

Abre la terminal integrada de VS Code (`Ctrl + ñ`, o menú **Terminal > New
Terminal**) y ejecuta estos comandos, en este orden:

**1. Confirmar que Git está instalado**

```
git --version
```

Debe responder con un número de versión (ej: `git version 2.44.0`). Si dice
que el comando no se reconoce, instala Git desde
[git-scm.com](https://git-scm.com/) antes de continuar.

**2. Confirmar que la carpeta está vinculada a un repositorio**

```
git remote -v
```

Debe mostrar una URL de GitHub, repetida dos veces (`fetch` y `push`), por
ejemplo:

```
origin  https://github.com/tuusuario/tu-repositorio.git (fetch)
origin  https://github.com/tuusuario/tu-repositorio.git (push)
```

Si no muestra nada, la carpeta no está vinculada a ningún repositorio
todavía — necesitas crear el repositorio en GitHub y vincularlo antes de
poder sincronizar cambios.

**3. Confirmar si hay cambios sin subir**

```
git status
```

Los mensajes posibles y qué significan:

- `Your branch is up to date with 'origin/main'.` y `nothing to commit,
  working tree clean` → todo está sincronizado, no falta nada.
- `Your branch is ahead of 'origin/main' by N commit(s).` → tienes commits
  hechos localmente que **todavía no subiste**. Necesitas hacer
  **Sync Changes** desde el panel de Source Control.
- Archivos listados en rojo bajo `Changes not staged for commit` →
  hiciste cambios que **ni siquiera** llevas a un commit todavía.

**Regla práctica para cada sesión:** antes de cerrar VS Code, corre
`git status` una vez más. Si no dice `working tree clean` y `up to date`,
todavía te falta un Commit y/o un Sync Changes.

## Estructura del proyecto

```
gastos-familiares/
├── index.html          -> Estructura de la página (dashboard, protegida por login)
├── login.html           -> Página de inicio de sesión / registro
├── css/
│   └── style.css        -> Todo el diseño visual (incluye toasts y login)
├── js/
│   ├── supabaseClient.js -> Ya tiene claves de ejemplo; edítalo si usas tu propio Supabase
│   ├── toast.js           -> Notificaciones discretas (reemplaza alert())
│   ├── auth.js             -> Registro, login y control de sesión
│   ├── login.js             -> Lógica del formulario de login.html
│   └── app.js                -> CRUD de gastos, dashboard y foto familiar
├── sql/
│   ├── schema.sql                          -> Tablas: gastos, familia, perfiles
│   ├── migracion_01_storage_policies.sql   -> Políticas de Storage (foto familiar)
│   └── migracion_02_rls_gastos.sql          -> Trigger de perfil + RLS real en gastos
└── README.md
```

## Flujo de trabajo (paso a paso)

### 1. Crear tu proyecto en Supabase

1. Entra a [supabase.com](https://supabase.com) e inicia sesión.
2. Clic en **New project**.
3. Ponle un nombre (ej: `gastos-familiares-tunombre`) y una contraseña de
   base de datos (guárdala, la puedes necesitar después).
4. Espera a que el proyecto termine de crearse (1-2 minutos).

### 2. Crear las tablas

1. En el menú lateral, entra a **SQL Editor**.
2. Clic en **New query**.
3. Abre el archivo `sql/schema.sql` de este proyecto, copia todo su
   contenido y pégalo en el editor.
4. Clic en **Run**. Deberías ver las tablas `familia`, `perfiles` y
   `gastos` creadas en **Table Editor**.

> **Para tener la versión de referencia 100% funcional** (con login y
> RLS ya activos, como viene este zip), después de este paso ejecuta
> también, en este mismo orden: `sql/migracion_01_storage_policies.sql`
> (sección 3.1 más abajo), y al final
> `sql/migracion_02_rls_gastos.sql` (después de desactivar "Confirm
> email" en Authentication > Settings, ver sección de Tarea 2, Paso 3.1).

### 3. Crear el bucket de almacenamiento (para la foto familiar)

1. En el menú lateral, entra a **Storage**.
2. Clic en **New bucket**.
3. Nombre exacto: `fotos-familia`.
4. Activa la opción **Public bucket**.
5. Clic en **Create bucket**.

### 3.1. Ejecutar la migración de políticas de Storage (obligatorio)

Aunque el bucket sea público, Supabase igual bloquea la subida de archivos
si no existen políticas explícitas sobre `storage.objects`. Sin este paso,
verás el error `new row violates row-level security policy` al intentar
subir la foto familiar.

1. Ve a **SQL Editor > New query**.
2. Abre el archivo `sql/migracion_01_storage_policies.sql` de este proyecto,
   copia todo su contenido y pégalo en el editor.
3. Clic en **Run**.
4. Si Supabase muestra el aviso "Potential issue detected" (por crear
   políticas sin RLS activado en otras tablas), no aplica en este caso
   porque aquí sí se están creando políticas — simplemente confirma
   con **Run**.

### 4. Conectar tu proyecto con tus claves

Este proyecto ya viene con una URL y anon key configuradas en
`js/supabaseClient.js` a modo de ejemplo funcional. Si vas a usar tu
**propio** proyecto de Supabase (recomendado para que cada quien tenga
su propia base de datos independiente), reemplázalas por las tuyas:

1. En Supabase, ve a **Project Settings > API**.
2. Copia el valor de **Project URL**.
3. Copia el valor de **anon public key**.
4. Abre el proyecto en VS Code.
5. Abre el archivo `js/supabaseClient.js`.
6. Reemplaza los valores de `SUPABASE_URL` y `SUPABASE_ANON_KEY` por los
   tuyos.
7. Guarda el archivo.

> La `anon key` **no es secreta**, puede ir en el frontend sin problema.
> Lo que realmente protege los datos son las políticas de seguridad (RLS)
> configuradas dentro de Supabase, no el hecho de ocultar esta clave.

### 5. Probar la app en tu computadora

1. En VS Code, instala la extensión **Live Server**.
2. Clic derecho sobre `index.html` > **Open with Live Server**.
3. Prueba registrar un gasto y subir una foto familiar.

### 6. Subir el proyecto a GitHub

**Opción A — Primera subida (arrastrar archivos)**

1. Entra a [github.com](https://github.com) e inicia sesión.
2. Clic en **New repository**.
3. Ponle un nombre (ej: `gastos-familiares`) y créalo vacío (sin README).
4. Dentro del repositorio, clic en **Add file > Upload files**.
5. Arrastra **todos los archivos y carpetas** del proyecto a la ventana.
   Importante: arrastra el **contenido** de la carpeta (`index.html`,
   `css/`, `js/`, `sql/`, `README.md`), no la carpeta contenedora completa
   — si arrastras la carpeta con su nombre, GitHub crea una subcarpeta
   extra y el sitio no va a funcionar al desplegarlo.
6. Escribe un mensaje de commit (ej: "Primera versión") y clic en
   **Commit changes**.

**Opción B — Subidas siguientes (recomendada, sin riesgo de duplicar carpetas)**

A partir de la Tarea 2 vas a modificar el proyecto varias veces, así que
conviene usar el panel de **Source Control** de VS Code en vez de volver
a arrastrar archivos:

1. En VS Code, clic en el ícono de **Source Control** (la ramificación,
   en la barra lateral izquierda).
2. Vas a ver listados automáticamente todos los archivos que modificaste
   o creaste, sin necesidad de tenerlos abiertos.
3. Escribe un mensaje corto en la cajita de arriba (ej: "Rediseño de
   frontend").
4. Clic en **Commit**. Si aparece un aviso de "no staged changes",
   clic en **Yes**.
5. Clic en **Sync Changes** para subir los cambios a GitHub.
6. Si te pide autenticarte y falla con "Repository not found" después
   de loguearte por el navegador, usa la opción **"Sign in with a code"**
   en vez del botón de navegador — copia el código de 8 caracteres que
   te muestra la consola, ábrelo en `https://github.com/login/device`,
   inicia sesión con tu cuenta y pega el código ahí.

### 7. Desplegar en Vercel

1. Entra a [vercel.com](https://vercel.com) e inicia sesión con tu cuenta
   de GitHub.
2. Clic en **Add New > Project**.
3. Selecciona el repositorio que acabas de subir.
4. No necesitas cambiar ninguna configuración (es un sitio estático).
5. Clic en **Deploy**.
6. En unos segundos tendrás un link público, por ejemplo:
   `https://gastos-familiares-tunombre.vercel.app`

Cada vez que subas cambios nuevos a GitHub (Commit + Sync Changes), Vercel
va a volver a desplegar la app automáticamente con esos cambios — no
necesitas hacer nada extra en Vercel.

## Próximos pasos (fase de escalabilidad)

Este proyecto está preparado para crecer sin romperse:

- La tabla `gastos` ya tiene la columna `usuario_id`, lista para cuando
  se active login con Supabase Auth.
- La tabla `perfiles` ya existe, lista para asignar roles
  (`admin`, `padre`, `madre`, `hijo`).
- Las políticas de seguridad (RLS) están comentadas dentro de
  `sql/schema.sql`, listas para activarse en la siguiente fase.

Esta fase se desarrolla a continuación, en la Tarea 2.

---

# Tarea 2 — Rediseño de interfaz, login y roles

Esta segunda parte se hace en dos sesiones, sobre este mismo proyecto ya
desplegado. Sigue el orden de las secciones tal cual está escrito, no
saltes pasos.

## 1. Qué puedes modificar y qué no puedes tocar

Todo el diseño vive en `css/style.css`. El archivo `js/app.js` no depende
de cómo se ve nada, solo de que ciertos elementos existan con su `id`
exacto en el HTML. Mientras esos `id` no cambien, puedes rediseñar todo
lo visual sin miedo a romper el sistema.

**Puedes cambiar libremente:** colores, tipografía, espaciados,
animaciones, orden visual de las secciones, tamaños, textos que no sean
atributos `id`, y agregar elementos decorativos nuevos.

**No debes cambiar el texto de estos `id`**, están escritos en
`index.html` y `app.js` los busca por ese nombre exacto:

| Sección | `id` que no se toca |
|---|---|
| Formulario de gasto | `gastoId`, `descripcion`, `monto`, `categoria`, `fecha` |
| Estadísticas del dashboard | `statTotal`, `statMes`, `statCantidad`, `statCategoriaTop` |
| Listado de gastos | `tablaGastosBody` |
| Categorías | `categoriasContainer` |
| Foto familiar | `inputFoto`, `fotoFamiliar`, `nombreFamilia` |

Regla simple: si en el HTML ves algo escrito como `id="algo"`, ese texto
no se toca — ahí es donde `app.js` va a buscar ese elemento.

## 2. Reemplazar los `alert()` por notificaciones tipo toast

**Sesión del 12 de agosto**

### Paso 2.1 — Crear el archivo `js/toast.js`

Dentro de la carpeta `js/`, crea un archivo nuevo llamado `toast.js`
(clic derecho sobre la carpeta `js` en VS Code > New File) con este
contenido exacto:

```javascript
function mostrarToast(mensaje, tipo = "exito") {
  const toast = document.createElement("div");
  toast.className = `toast toast--${tipo}`;
  toast.textContent = mensaje;
  document.body.appendChild(toast);
  setTimeout(() => toast.remove(), 3000);
}
```

### Paso 2.2 — Agregar el estilo del toast

Abre `css/style.css`, ve hasta el final del archivo, y agrega estas
líneas después de todo lo que ya existe (no reemplaces nada, solo agrega
al final):

```css
.toast {
  position: fixed;
  bottom: 20px;
  right: 20px;
  padding: 0.8rem 1.2rem;
  border-radius: 8px;
  color: #fff;
  font-size: 0.9rem;
  animation: subir 0.3s ease;
  z-index: 999;
}
.toast--exito { background: #10b981; }
.toast--error { background: #ef4444; }

@keyframes subir {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}
```

### Paso 2.3 — Enlazar `toast.js` en `index.html`

Abre `index.html` y busca, cerca del final del archivo (antes de
`</body>`), este bloque:

```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script src="js/supabaseClient.js"></script>
<script src="js/app.js"></script>
```

Reemplázalo exactamente por este (se agrega una línea nueva de
`toast.js`, en medio, antes de `app.js`):

```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script src="js/supabaseClient.js"></script>
<script src="js/toast.js"></script>
<script src="js/app.js"></script>
```

Este orden es obligatorio: el navegador carga los archivos de arriba
hacia abajo, y `app.js` necesita que `mostrarToast()` ya exista cuando
se ejecuta, por eso `toast.js` va antes.

### Paso 2.4 — Reemplazar cada `alert()` en `app.js`

Abre `js/app.js` y reemplaza, una por una, estas 6 líneas exactas:

**Línea ~79**, dentro del bloque de subir foto:
```javascript
// Antes:
alert("Error al subir la foto: " + uploadError.message);
// Después:
mostrarToast("Error al subir la foto: " + uploadError.message, "error");
```

**Línea ~95**, mismo bloque, un poco más abajo:
```javascript
// Antes:
alert("Error al guardar la foto: " + updateError.message);
// Después:
mostrarToast("Error al guardar la foto: " + updateError.message, "error");
```

**Línea ~119**, dentro de `form.addEventListener("submit", ...)`:
```javascript
// Antes:
if (error) return alert("Error al actualizar: " + error.message);
// Después:
if (error) return mostrarToast("Error al actualizar: " + error.message, "error");
```

**Línea ~122**, justo debajo de la anterior:
```javascript
// Antes:
if (error) return alert("Error al guardar: " + error.message);
// Después:
if (error) return mostrarToast("Error al guardar: " + error.message, "error");
```

**Línea ~180**, dentro de `window.editarGasto = async function (id) {`:
```javascript
// Antes:
if (error) return alert("Error: " + error.message);
// Después:
if (error) return mostrarToast("Error: " + error.message, "error");
```

**Línea ~198**, dentro de `window.eliminarGasto = async function (id) {`:
```javascript
// Antes:
if (error) return alert("Error al eliminar: " + error.message);
// Después:
if (error) return mostrarToast("Error al eliminar: " + error.message, "error");
```

Además, justo después de la línea `resetForm();` dentro de
`form.addEventListener("submit", ...)` (línea ~125), agrega una
confirmación de éxito:

```javascript
resetForm();
mostrarToast("Gasto guardado correctamente", "exito");
await cargarGastos();
```

## 3. Login con Supabase Auth

**Sesión del 14 de agosto**

### Paso 3.1 — Desactivar la confirmación de correo

Antes de escribir código, entra a tu proyecto de Supabase:

1. Ve a **Authentication > Settings** (o **Authentication > Providers >
   Email**).
2. Busca la opción **"Confirm email"**.
3. Desactívala.
4. Guarda los cambios.

Esto es obligatorio porque vas a registrar usuarios con correos tipo
`estudiante@colegio.edu`, que no reciben correos reales. Sin este paso,
no podrás iniciar sesión después de registrarte.

### Paso 3.2 — Crear el archivo `js/auth.js`

Dentro de la carpeta `js/`, crea un archivo nuevo llamado `auth.js` con
este contenido exacto:

```javascript
async function registrar(email, password) {
  const { data, error } = await supabase.auth.signUp({ email, password });
  return { data, error };
}

async function iniciarSesion(email, password) {
  const { data, error } = await supabase.auth.signInWithPassword({ email, password });
  return { data, error };
}

supabase.auth.onAuthStateChange((event, session) => {
  if (!session) window.location.href = "login.html";
});
```

### Paso 3.3 — Enlazar `auth.js` en `index.html`

Vuelve al mismo bloque de `index.html` que editaste en el Paso 2.3, y
agrega `auth.js` justo después de `toast.js` y antes de `app.js`:

```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script src="js/supabaseClient.js"></script>
<script src="js/toast.js"></script>
<script src="js/auth.js"></script>
<script src="js/app.js"></script>
```

Orden final obligatorio: librería de Supabase → tu conexión → toast →
auth → lógica principal (`app.js`).

### Paso 3.4 — Crear el trigger de perfil automático

En el **SQL Editor** de tu proyecto de Supabase, ejecuta este código
(crea automáticamente una fila en `perfiles` cada vez que alguien se
registra):

```sql
create or replace function crear_perfil_automatico()
returns trigger as $$
begin
  insert into public.perfiles (id, nombre, rol)
  values (new.id, new.email, 'sin_asignar');
  return new;
end;
$$ language plpgsql security definer set search_path = public;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function crear_perfil_automatico();
```

## 4. Ajuste obligatorio en `app.js` para guardar el usuario del gasto

**Sesión del 14 de agosto, después del Paso 3**

Abre `js/app.js` y busca este bloque exacto (dentro de
`form.addEventListener("submit", ...)`, aproximadamente en la línea
106):

```javascript
form.addEventListener("submit", async (e) => {
  e.preventDefault();

  const gasto = {
    descripcion: document.getElementById("descripcion").value.trim(),
    monto: parseFloat(document.getElementById("monto").value),
    categoria: document.getElementById("categoria").value,
    fecha: document.getElementById("fecha").value,
  };
```

Reemplázalo exactamente por este (se agrega la obtención del usuario y
el campo `usuario_id`):

```javascript
form.addEventListener("submit", async (e) => {
  e.preventDefault();

  const { data: { user } } = await supabase.auth.getUser();

  const gasto = {
    descripcion: document.getElementById("descripcion").value.trim(),
    monto: parseFloat(document.getElementById("monto").value),
    categoria: document.getElementById("categoria").value,
    fecha: document.getElementById("fecha").value,
    usuario_id: user.id,
  };
```

No cambies nada más de ese bloque, solo esas líneas agregadas.

## 5. Activar la seguridad real (RLS) en la tabla `gastos`

**Sesión del 14 de agosto, al final, después de haber probado que el
login y el Paso 4 funcionan**

En la carpeta `sql/` de tu proyecto, crea un archivo nuevo llamado
`migracion_02_rls_gastos.sql` con este contenido:

```sql
-- =========================================================
-- MIGRACIÓN 02: Activación de RLS real en la tabla gastos
-- =========================================================
-- Requiere que el login (Supabase Auth) ya esté implementado
-- y que app.js incluya usuario_id al insertar un gasto (Paso 4).
-- =========================================================

alter table gastos enable row level security;

create policy "usuarios ven solo sus gastos"
on gastos for select
using (auth.uid() = usuario_id);

create policy "usuarios insertan sus propios gastos"
on gastos for insert
with check (auth.uid() = usuario_id);

create policy "usuarios editan solo sus gastos"
on gastos for update
using (auth.uid() = usuario_id);

create policy "usuarios eliminan solo sus gastos"
on gastos for delete
using (auth.uid() = usuario_id);
```

Copia ese mismo contenido y ejecútalo en el **SQL Editor** de tu
proyecto de Supabase.

**Importante:** las 4 políticas (select, insert, update, delete) deben
ejecutarse juntas, en el mismo momento. Si activas
`enable row level security` sin las 4, tu tabla `gastos` va a quedar
bloqueada para todos — vas a ver "0 gastos" aunque sí tengas datos
guardados. Eso no es un error, es el comportamiento normal de seguridad
de Supabase cuando falta alguna política.

## Orden final que debe quedar en `index.html`

Después de completar las secciones 2 y 3, el bloque de scripts al final
de `index.html` debe verse exactamente así:

```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script src="js/supabaseClient.js"></script>
<script src="js/toast.js"></script>
<script src="js/auth.js"></script>
<script src="js/app.js"></script>
</body>
</html>
```

## Resumen de archivos por sesión — Tarea 2

| Sesión | Archivos que creas o modificas |
|---|---|
| 12 de agosto | `js/toast.js` (nuevo), `css/style.css` (agregar al final), `index.html` (agregar línea de script), `js/app.js` (reemplazar 6 `alert()`) |
| 14 de agosto | `js/auth.js` (nuevo), `index.html` (agregar línea de script), `js/app.js` (ajuste del Paso 4), `sql/migracion_02_rls_gastos.sql` (nuevo) |

## Errores comunes ya identificados (y su solución)

| Error | Causa | Solución |
|---|---|---|
| Carpeta duplicada en GitHub | Se arrastró la carpeta contenedora en vez de su contenido | Volver a subir solo el contenido, o usar Source Control desde VS Code |
| `Identifier 'supabase' has already been declared` | Live Server inyecta el script dos veces | El código de `supabaseClient.js` ya está protegido con una función que evita este error |
| `new row violates row-level security policy` al subir la foto | Falta el bucket `fotos-familia` o sus políticas de Storage | Verificar bucket público + ejecutar `migracion_01_storage_policies.sql` |
| Imagen no carga (404 Object not found) | Quedó guardada una URL de un intento fallido anterior | `update familia set foto_url = null;` y volver a subir la foto |
| `git push` falla con "Repository not found" tras autenticarse | El navegador autenticó con una cuenta de GitHub distinta a la dueña del repo | Usar "Sign in with a code" (device login) en vez del botón de navegador |
| Tabla `gastos` aparece vacía tras activar RLS | Se activó `enable row level security` sin crear las 4 políticas | Ejecutar las 4 políticas de la Sección 5 juntas, en la misma sesión |