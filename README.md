# 🎓 OnCourses App — Cliente Móvil (Flutter)

Este repositorio contiene el código fuente de la aplicación móvil **OnCourses**, desarrollada en **Flutter** para la asignatura de *Tecnologías de la Programación IV*. La aplicación consume los servicios de la **API REST de OnCourses** desarrollada en **Django** y desplegada en producción.

La aplicación implementa una estructura de **Clean Architecture** (Arquitectura Limpia) simplificada y un sistema de control de acceso basado en roles (**RBAC**).

---

## 🚀 Requisitos Previos

Asegúrate de tener instalados los siguientes componentes antes de ejecutar el proyecto:
*   **Flutter SDK** (Versión `3.12.0` o superior).
*   **Dart SDK** (Versión `3.0.0` o superior).
*   **Android Studio** o **VS Code** con las extensiones oficiales de Flutter y Dart.
*   Un emulador (Android/iOS) o un dispositivo físico configurado para desarrollo.

---

## 🛠️ Instalación y Ejecución

Sigue estos pasos para clonar el proyecto y ponerlo en marcha en tu entorno local:

1.  **Clonar el repositorio:**
    ```bash
    git clone -b dev <url-de-tu-repositorio-github>
    cd on-courses-app
    ```

2.  **Configurar las variables de entorno:**
    Duplica el archivo de plantilla `.env.example`, renombralo a `.env` en la raíz del proyecto y ajusta la URL del servidor si es necesario:
    ```bash
    # En Windows PowerShell
    Copy-Item .env.example .env
    ```
    El archivo `.env` configurado debe verse así:
    ```env
    API_URL=https://on-courses-api.uaeftt-ute.site/api
    CONNECTION_TIMEOUT=5000
    RECEIVE_TIMEOUT=3000
    ```

3.  **Instalar las dependencias de Flutter:**
    ```bash
    flutter pub get
    ```

4.  **Ejecutar la aplicación:**
    Asegúrate de tener un emulador encendido o tu dispositivo físico conectado y ejecuta:
    ```bash
    flutter run
    ```

---

## 🔑 Credenciales de Prueba Recomendadas

Para probar las restricciones de rol en las secciones protegidas, utiliza las siguientes cuentas registradas en el backend de producción:

| Rol | Usuario (Username) | Contraseña (Password) | Permisos |
| :--- | :--- | :--- | :--- |
| **Estudiante** | `student_test` *(o regístrate en la app)* | `studentPass123` | Catálogo público, carrito, matricularse, mis cursos, perfil. |
| **Profesor / Docente** | `prof_test` | `profPass123` | Crear y editar cursos/categorías (CRUD parcial). Eliminación deshabilitada. |
| **Administrador** | `admin_test` | `adminPass123` | Acceso completo. Puede crear, editar y eliminar cursos/categorías. |

---

## 📂 Estructura de Arquitectura del Proyecto

El código de la aplicación sigue estrictamente el árbol de arquitectura limpia provisto:

*   **`lib/core/`**: Configuraciones generales de la app (`app_config.dart`), manejo de excepciones de la API (`api_exception.dart`) y utilidades comunes como validadores de formularios y formateadores.
*   **`lib/domain/`**: Capa del dominio puro. Contiene los modelos de negocio (`user.dart`, `product.dart` para cursos, `order.dart`, etc.) y las definiciones de interfaces de repositorios (`auth_repository.dart`, `catalog_repository.dart`). No tiene dependencias de red ni persistencia.
*   **`lib/data/`**: Capa de datos concretos. Contiene los DTOs para deserialización del JSON del backend, los wrappers para encriptación de datos persistentes (`secure_storage.dart`), la configuración de llamadas HTTP de `Dio` con su respectivo interceptor de JWT (`auth_interceptor.dart`), y las implementaciones concretas de los repositorios.
*   **`lib/presentation/`**: Capa visual. Se compone de enrutamiento con guards (`app_router.dart` de GoRouter), gestores de estado basados en `provider` (`auth_provider.dart`, `cart_provider.dart`, `catalog_provider.dart`, `admin_provider.dart`), widgets modulares y las pantallas de usuario (públicas, privadas de compras y administrativas).
*   **`lib/theme/`**: Centralización de la identidad visual de la app (colores premium Navy/Amber, tipografías Outfit/Inter y configuración de `ThemeData`).

---

## 📸 Capturas de Pantalla Obligatorias (Evidencias)

> [!NOTE]
> *Reemplaza los archivos de imagen a continuación con tus capturas funcionales una vez desplegado en tu dispositivo o emulador para la entrega final.*

### 1. Pantalla Pública Principal (Catálogo)
Muestra el catálogo de cursos listado desde la API con sus filtros por categoría.
`![Catálogo Público](docs/screenshots/catalog_screen.png)`

### 2. Formulario de Login
Inicio de sesión que consume el token JWT.
`![Login](docs/screenshots/login_screen.png)`

### 3. Pantalla Principal Privada (Mi Perfil con Rol)
Muestra la información del usuario autenticado y su insignia de rol correspondiente.
`![Perfil](docs/screenshots/profile_screen.png)`

### 4. Un Listado de API (Mis Matrículas)
Listado de compras/inscripciones del usuario autenticado.
`![Listado de Matrículas](docs/screenshots/orders_screen.png)`

### 5. Formulario Creando/Editando en el Panel de Admin
Formulario interactivo en BottomSheet guardando cambios de forma exitosa en la API.
`![Formulario CRUD](docs/screenshots/admin_form_screen.png)`

### 6. Ejemplo de Restricción por Rol
Muestra las acciones del panel de administración bloqueadas o invisibles (por ejemplo, el botón de eliminar no visible al estar logueado como Profesor, a diferencia del Administrador).
`![Restricción de Rol](docs/screenshots/rbac_restriction_screen.png)`

---

## 🎥 Evidencia Funcional en Video

El enlace al video demostrativo de funcionamiento real (3 a 5 minutos) con emulador/teléfono y consumo de endpoints de DigitalOcean es el siguiente:

👉 **[Enlace al Video de Demostración en YouTube / Google Drive](https://youtube.com/tu-video-de-evidencia-aqui)**
