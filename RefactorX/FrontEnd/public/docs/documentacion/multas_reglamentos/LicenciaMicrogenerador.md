# Documentación: LicenciaMicrogenerador

## Análisis Técnico

# Documentación Técnica: LicenciaMicrogenerador

## Descripción General
Este módulo permite consultar, registrar y cancelar el estatus de microgenerador para licencias o trámites en el sistema. La lógica se implementa en un stored procedure de PostgreSQL y se expone mediante un endpoint API unificado en Laravel. El frontend es una página Vue.js independiente.

## Arquitectura
- **Backend**: Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend**: Componente Vue.js como página completa, sin tabs.
- **Base de Datos**: PostgreSQL, lógica central en stored procedure `lic_registro_microgenerador`.

## API
### Endpoint
`POST /api/execute`

#### Request Body
```json
{
  "action": "consulta|alta|cancelar",
  "params": {
    "tipo": "L|T", // L=Licencia, T=Trámite
    "licencia": 123, // si tipo=L
    "tramite": 456,  // si tipo=T
    "id": 123,       // id_licencia o id_tramite para alta/cancelar
    "anio": 2024,    // opcional, default año actual
    "usuario": "usuario" // opcional, tomado del usuario autenticado si existe
  }
}
```

#### Respuesta
```json
{
  "estatus": 1, // 1=exitoso, 2=no existe, 0=error
  "mensaje": "Texto descriptivo",
  "licencia": { ... } // si aplica
}
```

## Stored Procedure
- **lic_registro_microgenerador**: Maneja consulta, alta y cancelación de microgenerador para licencias o trámites.
- Tabla sugerida: `lic_microgenerador(id_ref integer, anio smallint, usuario_alta varchar, fecha_alta timestamp, usuario_baja varchar, fecha_baja timestamp, vigente char(1))`

## Frontend
- Página Vue.js independiente
- Selección de tipo (Licencia/Trámite)
- Consulta, alta y cancelación con feedback visual
- Navegación simple, sin tabs

## Seguridad
- El usuario se toma del contexto autenticado o del parámetro `usuario`.
- Validaciones de existencia y estado en el stored procedure.

## Flujo de Trabajo
1. El usuario selecciona tipo y número de licencia/trámite.
2. Consulta el estatus actual.
3. Si no existe como microgenerador, puede dar de alta.
4. Si ya existe, puede cancelar.

## Errores y Mensajes
- Mensajes claros para cada acción y error.
- El estatus y mensaje se muestran en el frontend.

## Integración
- El endpoint `/api/execute` puede ser usado por cualquier frontend o sistema externo.
- El stored procedure centraliza la lógica de negocio y puede ser reutilizado por otros módulos.

## Casos de Uso

# Casos de Uso - LicenciaMicrogenerador

**Categoría:** Form

## Caso de Uso 1: Consulta de Licencia como Microgenerador

**Descripción:** El usuario consulta si una licencia está registrada como microgenerador.

**Precondiciones:**
La licencia existe y está vigente.

**Pasos a seguir:**
1. El usuario accede a la página de Licencia Microgenerador.
2. Selecciona 'Licencia' como tipo.
3. Ingresa el número de licencia.
4. Da clic en 'Consultar'.

**Resultado esperado:**
Se muestra la información de la licencia y el mensaje 'Ya existe como microgenerador' o 'No existe como microgenerador'.

**Datos de prueba:**
{ "tipo": "L", "licencia": 12345 }

---

## Caso de Uso 2: Alta de Licencia como Microgenerador

**Descripción:** El usuario registra una licencia como microgenerador.

**Precondiciones:**
La licencia existe, está vigente y no está registrada como microgenerador.

**Pasos a seguir:**
1. El usuario consulta la licencia como en el caso anterior.
2. Si el mensaje es 'No existe como microgenerador', da clic en 'Registrar como microgenerador'.

**Resultado esperado:**
El sistema muestra el mensaje 'Alta exitosa, Licencia registrada como microgenerador'.

**Datos de prueba:**
{ "tipo": "L", "id": 12345 }

---

## Caso de Uso 3: Cancelación de Licencia como Microgenerador

**Descripción:** El usuario cancela el registro de una licencia como microgenerador.

**Precondiciones:**
La licencia está registrada como microgenerador.

**Pasos a seguir:**
1. El usuario consulta la licencia.
2. Si el mensaje es 'Ya existe como microgenerador', da clic en 'Cancelar microgenerador'.

**Resultado esperado:**
El sistema muestra el mensaje 'Cancelación exitosa, Licencia cancelada como microgenerador'.

**Datos de prueba:**
{ "tipo": "L", "id": 12345 }

---

## Casos de Prueba

# Casos de Prueba: LicenciaMicrogenerador

## 1. Consulta de Licencia Vigente
- **Entrada:**
  - action: consulta
  - params: { tipo: 'L', licencia: 12345 }
- **Esperado:**
  - estatus: 1 o 2
  - mensaje: 'Ya existe como microgenerador' o 'No existe como microgenerador'
  - licencia: objeto con datos

## 2. Alta de Microgenerador
- **Entrada:**
  - action: alta
  - params: { tipo: 'L', id: 12345 }
- **Esperado:**
  - estatus: 1
  - mensaje: 'Alta exitosa, Licencia registrada como microgenerador'

## 3. Cancelación de Microgenerador
- **Entrada:**
  - action: cancelar
  - params: { tipo: 'L', id: 12345 }
- **Esperado:**
  - estatus: 1
  - mensaje: 'Cancelación exitosa, Licencia cancelada como microgenerador'

## 4. Consulta de Licencia Inexistente
- **Entrada:**
  - action: consulta
  - params: { tipo: 'L', licencia: 99999 }
- **Esperado:**
  - estatus: 0
  - mensaje: 'Licencia no vigente'

## 5. Alta de Microgenerador ya Existente
- **Entrada:**
  - action: alta
  - params: { tipo: 'L', id: 12345 }
- **Precondición:** Ya existe como microgenerador
- **Esperado:**
  - estatus: 0
  - mensaje: 'Ya existe como microgenerador'

## 6. Cancelación de Microgenerador Inexistente
- **Entrada:**
  - action: cancelar
  - params: { tipo: 'L', id: 99999 }
- **Esperado:**
  - estatus: 0
  - mensaje: 'No se encontró registro vigente para cancelar'

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

