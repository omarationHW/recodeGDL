# Documentación Técnica: Migración de Formulario ModuloBD (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel 10+ (PHP 8.1+), API RESTful, endpoint único `/api/execute`.
- **Frontend**: Vue.js 3 (SPA), cada formulario es una página independiente.
- **Base de Datos**: PostgreSQL 14+, lógica de negocio en stored procedures.
- **Patrón de Comunicación**: eRequest/eResponse (JSON), desacoplado de la UI.

## API Unificada
- **Endpoint**: `/api/execute` (POST)
- **Entrada**: `{ eRequest: { action: 'nombreAccion', params: { ... } } }`
- **Salida**: `{ eResponse: { success: bool, error: string|null, data: any } }`
- **Acciones soportadas**: getTipos, addTipo, updateTipo, deleteTipo, ...

## Controlador Laravel
- Centraliza todas las acciones del módulo.
- Valida parámetros y delega a los stored procedures.
- Maneja errores y retorna eResponse estándar.

## Componente Vue.js
- Página independiente para cada catálogo (ejemplo: Tipos).
- CRUD completo: listar, agregar, editar, eliminar.
- Modal para alta/edición.
- Navegación breadcrumb.
- Manejo de errores y feedback visual.

## Stored Procedures PostgreSQL
- Cada operación de catálogo es un SP (get, add, update, delete).
- Los SP retornan siempre un registro (o tabla) para facilitar el consumo.
- Manejo de errores a nivel SQL mediante excepciones.

## Seguridad
- Validación de parámetros en backend y frontend.
- Uso de prepared statements en Laravel.
- No se exponen queries directos al frontend.

## Extensibilidad
- Para agregar nuevos catálogos, replicar patrón de SP, métodos en el controlador y vistas.
- El endpoint `/api/execute` puede enrutar a cualquier lógica de negocio.

## Ejemplo de Flujo (Alta de Tipo)
1. Usuario abre página de Tipos (Vue).
2. Vue llama a `/api/execute` con `{ action: 'getTipos' }` y muestra la tabla.
3. Usuario da clic en "Agregar", ingresa descripción y guarda.
4. Vue llama a `/api/execute` con `{ action: 'addTipo', params: { descripcion: '...' } }`.
5. Laravel ejecuta `sp_add_tipo`, retorna el nuevo registro.
6. Vue refresca la tabla.

## Consideraciones de Migración
- Todos los formularios Delphi se migran a páginas Vue independientes.
- No se usan tabs ni componentes tabulares.
- La lógica de negocio y validaciones se centralizan en el backend.
- El frontend sólo orquesta la UI y la interacción.

## Estructura de Carpetas Sugerida
- `app/Http/Controllers/ModuloBDController.php`
- `resources/js/pages/ModuloBDTiposPage.vue`
- `database/migrations/` (estructura de tablas)
- `database/functions/` (stored procedures)

## Pruebas y QA
- Casos de uso y pruebas unitarias para cada endpoint y SP.
- Pruebas de integración frontend-backend.
- Validación de errores y mensajes de usuario.

---
