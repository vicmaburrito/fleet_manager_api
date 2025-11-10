# Fleet Manager API

Gestión de flotas y servicios de mantenimiento desarrollado en Ruby on Rails. API RESTful protegida con JWT, un sistema de reportes agregados y manejo de estados automatizado.

## Stack Tecnológico

  * **Lenguaje:** Ruby 3.x
  * **Framework:** Rails 7.x
  * **Base de Datos:** PostgreSQL
  * **Autenticación:** JWT (Manual)
  * **Testing:** Rspec,RSwagger, FactoryBot

-----

## Documentación de la API (Swagger)

La API está completamente documentada utilizando **Swagger UI** (generado por RSwag). Esto permite la exploración interactiva de todos los *endpoints* sin necesidad de herramientas externas.

**Acceso Interactivo:**
Una vez que el servidor esté corriendo (`rails s`), accede a:

```
http://localhost:3000/api-docs
```

Aquí podrás probar cada *endpoint* directamente desde el navegador, incluyendo la autenticación JWT.

-----

## Configuración

### 1\. Requisitos

Asegúrate de tener **Ruby 3.x** y **PostgreSQL** instalados en tu sistema.

### 2\. Setup Local

Clona el repositorio y configura el entorno:

```bash
git clone https://github.com/vicmaburrito/fleet_manager_api
cd fleet_manager_api
bundle install
```

### 3\. Base de Datos

Crea la base de datos, aplica las migraciones y carga los datos iniciales:

```bash
rails db:create
rails db:migrate
rails db:seed
```

### 4\. Ejecución

Inicia el servidor de Rails:

```bash
rails s
```

La API estará disponible en `http://localhost:3000`.

-----

## Autenticación

Todos los endpoints de la API (excepto el de `login`) requieren un **Bearer Token JWT** válido en el encabezado `Authorization`.

| Endpoint | Método | Descripción |
| :--- | :--- | :--- |
| `/api/v1/auth/login` | `POST` | Genera el token JWT. |

**Ejemplo de Petición:**

```
POST /api/v1/auth/login
Content-Type: application/json

{ "email": "admin@flota.com", "password": "password123" }
```

Utiliza el token resultante en el encabezado: `Authorization: Bearer <TOKEN_JWT>`.

## 🧪 Pruebas

La aplicación utiliza **RSpec** para una alta cobertura de modelos, lógica de negocio (Servicios/Reglas), y contratos de API (Requests).

Ejecuta el conjunto completo de pruebas con:

```bash
bundle exec rspec
```

## Endpoints Clave (Reportes y CRUD)

| Endpoint | Método | Función | Notas |
| :--- | :--- | :--- | :--- |
| `/api/v1/vehicles` | `GET` | Listado y búsqueda de vehículos. | Soporta filtros, paginación y ordenamiento. |
| `/api/v1/vehicles/:id/maintenance_services` | `POST` | Crea un servicio para el vehículo. | Actualiza automáticamente `Vehicle.status` a `in_maintenance`. |
| `/api/v1/maintenance_services/:id` | `PATCH` | Actualiza un servicio. | Manejo de lógica de transición de estado y *soft delete*. |
| **`/api/v1/reports/maintenance_summary`** | `GET` | **Reporte agregado.** | **Acepta `?from=` y `?to=`. Soporta `format=csv`.** |

### Ejemplo: Obtener Reporte

```
GET /api/v1/reports/maintenance_summary?from=2025-01-01&to=2025-06-30
```
