# Documentación Técnica: Dscto_p_pago

## Análisis

# Documentación Técnica: Descuentos por Pronto Pago (Dscto_p_pago)

## Descripción General
Este módulo permite la administración de los descuentos por pronto pago aplicables a contratos, permitiendo:
- Alta de periodos de descuento (% y fechas)
- Consulta de todos los periodos
- Cancelación lógica de periodos (baja lógica)

## Arquitectura
- **Backend:** Laravel Controller (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (componente de página independiente)
- **Base de Datos:** PostgreSQL (tabla `ta_16_dscto_pp` y stored procedures)
- **API Pattern:** eRequest/eResponse

## API
### Endpoint
`POST /api/execute`

#### Request
```json
{
  "eRequest": {
    "action": "list|create|delete",
    "data": { ... }
  }
}
```

#### Actions
- `list`: Devuelve todos los descuentos activos y cancelados
- `create`: Crea un nuevo descuento (requiere: fecha_inicio, fecha_fin, porc_dscto, usuario_mov)
- `delete`: Cancela un descuento (requiere: id, usuario_mov)

#### Response
```json
{
  "eResponse": {
    "success": true|false,
    "message": "...",
    "data": [ ... ]
  }
}
```

## Stored Procedures
- `sp_dscto_pp_create(fecha_inicio, fecha_fin, porc_dscto, usuario_mov)`
- `sp_dscto_pp_delete(id, usuario_mov)`

## Validaciones
- No se permite crear descuentos con fechas o porcentaje inválidos
- Solo se puede cancelar descuentos con status 'V'

## Seguridad
- El usuario debe estar autenticado y autorizado para crear/cancelar descuentos (no implementado en este ejemplo, pero debe integrarse con Auth en producción)

## Frontend
- Página Vue.js independiente
- Formulario para alta
- Tabla para consulta y baja lógica
- Mensajes de éxito/error

## Integración
- El componente Vue.js consume el endpoint `/api/execute` usando el patrón eRequest/eResponse
- El backend ejecuta los stored procedures según la acción

## Tabla de Base de Datos
```sql
CREATE TABLE ta_16_dscto_pp (
    id SERIAL PRIMARY KEY,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    porc_dscto NUMERIC NOT NULL,
    status CHAR(1) NOT NULL DEFAULT 'V',
    fecha_at DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_in DATE NOT NULL DEFAULT CURRENT_DATE,
    usuario_mov VARCHAR(50) NOT NULL
);
```


## Casos de Uso

# Casos de Uso - Dscto_p_pago

**Categoría:** Form

## Caso de Uso 1: Registrar un nuevo descuento por pronto pago

**Descripción:** El usuario desea registrar un nuevo periodo de descuento por pronto pago para incentivar el pago anticipado.

**Precondiciones:**
El usuario tiene permisos de administrador y conoce las fechas y porcentaje de descuento.

**Pasos a seguir:**
1. Accede a la página de Descuentos por Pronto Pago.
2. Llena el formulario con fecha de inicio, fecha de fin, porcentaje de descuento y usuario.
3. Presiona 'Agregar'.
4. El sistema valida y registra el descuento.

**Resultado esperado:**
El nuevo descuento aparece en la tabla con status 'V'.

**Datos de prueba:**
{
  "fecha_inicio": "2024-07-01",
  "fecha_fin": "2024-07-31",
  "porc_dscto": 10.5,
  "usuario_mov": "admin"
}

---

## Caso de Uso 2: Cancelar un descuento vigente

**Descripción:** El usuario necesita cancelar un descuento vigente por error en las fechas.

**Precondiciones:**
Existe al menos un descuento con status 'V'.

**Pasos a seguir:**
1. Accede a la página de Descuentos por Pronto Pago.
2. Ubica el registro a cancelar en la tabla.
3. Presiona el botón 'Cancelar'.
4. Confirma la acción.

**Resultado esperado:**
El registro cambia su status a 'C' y no puede volver a ser cancelado.

**Datos de prueba:**
{
  "id": 1,
  "usuario_mov": "admin"
}

---

## Caso de Uso 3: Listar todos los descuentos

**Descripción:** El usuario desea consultar todos los periodos de descuento registrados.

**Precondiciones:**
Existen varios descuentos registrados.

**Pasos a seguir:**
1. Accede a la página de Descuentos por Pronto Pago.
2. Visualiza la tabla de registros.

**Resultado esperado:**
La tabla muestra todos los descuentos, tanto vigentes como cancelados.

**Datos de prueba:**
{}

---



## Casos de Prueba

# Casos de Prueba: Dscto_p_pago

## 1. Alta de descuento válido
- **Entrada:** fecha_inicio=2024-07-01, fecha_fin=2024-07-31, porc_dscto=10.5, usuario_mov=admin
- **Acción:** create
- **Esperado:** success=true, message contiene 'creado', registro aparece en list

## 2. Alta con porcentaje inválido
- **Entrada:** fecha_inicio=2024-07-01, fecha_fin=2024-07-31, porc_dscto=150, usuario_mov=admin
- **Acción:** create
- **Esperado:** success=false, message contiene 'porcentaje'

## 3. Cancelar descuento vigente
- **Precondición:** existe registro con id=1 y status='V'
- **Entrada:** id=1, usuario_mov=admin
- **Acción:** delete
- **Esperado:** success=true, registro con id=1 cambia a status='C'

## 4. Cancelar descuento ya cancelado
- **Precondición:** registro con id=1 y status='C'
- **Entrada:** id=1, usuario_mov=admin
- **Acción:** delete
- **Esperado:** success=true (no error), pero status permanece 'C'

## 5. Listar descuentos
- **Acción:** list
- **Esperado:** success=true, data es array de registros

## 6. Validación de campos obligatorios
- **Entrada:** fecha_inicio=2024-07-01, fecha_fin=2024-07-31, usuario_mov=admin (falta porc_dscto)
- **Acción:** create
- **Esperado:** success=false, message contiene 'porc_dscto'


