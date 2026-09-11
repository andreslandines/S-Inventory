# 📦 S-INVENTORY - GESTOR DE INVENTARIO INTELIGENTE

APLICACIÓN MÓVIL PARA GESTIONAR PRODUCTOS, FECHAS DE VENCIMIENTO Y REGISTRO DE VENTAS DE UNA TIENDA RURAL, DESARROLLADA CON UNA EXCELENTE TECNOLOGÍA

## 🛠 Stack Tecnológico

El proyecto utiliza una arquitectura moderna basada en un cliente móvil, un servidor backend y una base de datos en la nube, integrando las siguientes tecnologías:

- **Node.js + Express** (backend)
- **Supabase** (base de datos en la nube)
- **Flutter** (frontend)
- **JWT** para el manejo de sesiones

## 🚀 Características del Proyecto

### 🔒 1. Autenticación y Seguridad

- **Registro e Inicio de Sesión**: Autenticación segura para usuarios administrativos mediante tokens (JWT).
- **Control de Acceso Basado en Roles** (RBAC): Vistas y permisos solo para el perfil Administrador.

- **Protección de Rutas**: Middlewares en el backend para restringir el acceso a endpoints sensibles según el rol.

- **Gestión de Sesión**: Cierre de sesión seguro y expiración automática de credenciales.



### 📝 2. Panel Administrativo (Gestión de la Tienda)

- **CRUD de Productos**: Creación, actualización y desactivación de productos diversos.
- **Gestión de Categorías**: Organización de los productos (Comida, ropa, útiles, decoración, etc.).
- **Control de Inventario**: Gestión en tiempo real de precios, disponibilidad de cualquier producto.



### 👤 3. Catálogo Privado (Experiencia del Cliente con su inventario)

- **Navegación Interactiva**: Exploración por categorías de productos con diseño ágil e intuitivo.

- **Búsqueda Dinámica**: Filtro en tiempo real por nombre de producto, productos por vencer y productos ingresados recientemente.

- **Detalle del Producto**: Vista individual con fotos, características del producto, precios y fechas.



### 💵 4. Registro de Ventas

- **Gestión de Órdenes**: Generación de historial de productos vendidos.



## ⚙️ Instalación y Configuración

1. **Clonar el repositorio**
   - `git clone https://github.com/andreslandines/S-Inventory.git`
   - Instalación de Node
   - `npm install`
   - Instalar librería de Node Express
   - Instalar librería de Supabase

2. **Ejecutar el Servidor**
   - `npm run dev`



## 📁 Estructura del Proyecto

```text
S-Inventory/
├── backend/
│   ├── config/              # Config de Cloudinary y Supabase
│   ├── controllers/        # Lógica de cada recurso
│   ├── middlewares/       # Protección de rutas y auth
│   ├── models/            # Modelos de datos
│   ├── routes/           # Definición de rutas API
│   ├── utils/            # Envío de emails
│   └── index.js          # Punto de entrada del backend
└── frontend/
    └── s_inventory/      # App Flutter
        ├── lib/
        │   └── main.dart  # Código principal
        ├── android/        # Build de Android
        ├── ios/            # Build de iOS
        ├── web/            # Build de Web
        ├── linux/         # Build de Linux
        ├── macos/         # Build de macOS
        ├── windows/       # Build de Windows
        └── pubspec.yaml    # Dependencias de Flutter
```

---

## 👥 Autores

- **Andrés Felipe Landines Cardoso**
  - Aprendiz del SENA en Análisis y Desarrollo de Software
- **Dana Sofia Montoya Tovar**
  - Aprendiz del SENA en Análisis y Desarrollo de Software
