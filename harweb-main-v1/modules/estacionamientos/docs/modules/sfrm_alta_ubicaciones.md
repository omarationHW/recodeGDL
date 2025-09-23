# Documentación Técnica: Migración de Formulario sfrm_alta_ubicaciones

## 1. Descripción General
Este módulo permite dar de alta ubicaciones asociadas a un contrato de estacionamiento exclusivo. La migración incluye:
- Un endpoint API unificado (`/api/execute`) bajo el patrón eRequest/eResponse.
- Un controlador Laravel que procesa la petición y llama al stored procedure en PostgreSQL.
- Un componente Vue.js como página independiente para la captura de datos.
- Un stored procedure en PostgreSQL que realiza la inserción.

## 2. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "operation": "alta_ubicacion",
      "params": {
        "opc": 1,
        "id_ubic": 0,
        "contrato_id": 123,
        "tipo_esta": "C",
        "calle": "AV. PRINCIPAL",
        "colonia": "CENTRO",
        "zona": 0,
        "subzona": 0,
        "extencion": 20,
        "acera": "N",
        "inter": "CON 5 DE MAYO",
        "inter2": "",
        "apartir": 100,
        "hacia": "N",
        "usuario": 1
      }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "message": "Alta de Ubicación realizada correctamente.",
      "data": {
        "id": 45,
        "mensaje": "Alta de Ubicación realizada correctamente."
      }
    }
  }
  ```

## 3. Stored Procedure
- **Nombre:** sp_exc_ubicacion
- **Parámetros:**
  - `opc`: Operación (1 = Alta)
  - `id_ubic`: ID de ubicación (no usado en alta)
  - `contrato_id`: ID del contrato
  - `tipo_esta`: Tipo de estacionamiento ('C' = Cordon, 'B' = Bateria)
  - `calle`, `colonia`, `zona`, `subzona`, `extencion`, `acera`, `inter`, `inter2`, `apartir`, `hacia`, `usuario`
- **Retorno:**
  - `id`: ID de la ubicación insertada
  - `mensaje`: Mensaje de resultado

## 4. Controlador Laravel
- **Clase:** `App\Http\Controllers\Api\ExecuteController`
- **Método principal:** `execute(Request $request)`
- **Método de operación:** `altaUbicacion($params)`
- **Validación:** Se valida la presencia y tipo de los campos requeridos.
- **Ejecución:** Llama al stored procedure vía DB::select.
- **Respuesta:** Formato eResponse con éxito o error.

## 5. Componente Vue.js
- **Nombre:** `AltaUbicacionesPage`
- **Props requeridos:**
  - `contrato_id`: ID del contrato
  - `contrato_num`: Número o identificador del contrato
  - `usuario_id`: ID del usuario autenticado
- **Funcionalidad:**
  - Formulario con validación de campos
  - Llama a `/api/execute` con la operación `alta_ubicacion`
  - Muestra mensajes de éxito o error
  - Permite cancelar y regresar

## 6. Tabla de Base de Datos Sugerida
```sql
CREATE TABLE ubicaciones (
    id serial PRIMARY KEY,
    contrato_id integer NOT NULL,
    tipo_esta varchar(1) NOT NULL,
    calle varchar(255) NOT NULL,
    colonia varchar(255) NOT NULL,
    zona integer DEFAULT 0,
    subzona integer DEFAULT 0,
    extencion numeric NOT NULL,
    acera varchar(1) NOT NULL,
    inter varchar(255) NOT NULL,
    inter2 varchar(255) DEFAULT '',
    apartir integer NOT NULL,
    hacia varchar(1) NOT NULL,
    usuario_alta integer NOT NULL,
    fecha_alta timestamp NOT NULL DEFAULT NOW()
);
```

## 7. Seguridad
- El endpoint debe protegerse con autenticación (ej. Sanctum, JWT) y validación de usuario.
- El ID de usuario debe provenir del contexto autenticado, no del frontend.

## 8. Notas de Migración
- Los combos de "Acera" y "Hacia" usan la inicial del texto (N, S, O, P).
- El campo "tipo_esta" es 'C' para Cordon, 'B' para Bateria.
- Los campos "zona", "subzona", "inter2" pueden dejarse en 0 o vacío según el formulario.
- El formulario Vue es una página independiente, no un tab.

# Fin de documentación
