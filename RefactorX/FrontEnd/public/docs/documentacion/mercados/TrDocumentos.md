# TrDocumentos

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración de Formulario TrDocumentos (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la consulta y generación de archivos de transferencia electrónica de documentos (cheques y transferencias) a partir de la información almacenada en la base de datos. El proceso incluye filtros por fecha, cuenta y tipo de documento, así como la generación de archivos de texto para su procesamiento bancario.

## 2. Arquitectura
- **Backend**: Laravel API con endpoint unificado `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend**: Componente Vue.js como página independiente, con navegación y tabla de resultados.
- **Base de Datos**: PostgreSQL, con lógica de negocio encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Formato de entrada**:
  ```json
  {
    "eRequest": {
      "operation": "getDocumentos|getCuentasTrans|getBancosPagadores|generarTransferencia",
      "params": { ... }
    }
  }
  ```
- **Formato de salida**:
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [...],
      "message": ""
    }
  }
  ```

## 4. Stored Procedures
- **sp_get_documentos**: Consulta documentos filtrados.
- **sp_get_cuenta_trans**: Devuelve la cuenta de transferencia asociada a una cuenta.
- **sp_get_bancos_pagadores**: Devuelve bancos pagadores activos.
- **sp_generar_transferencia**: Genera el archivo de transferencia y retorna la URL de descarga.

## 5. Flujo de la Aplicación
1. El usuario selecciona fecha, cuenta y tipo de documento.
2. Al buscar, se consulta la API (`getDocumentos`) y se muestran los resultados.
3. El usuario puede generar el archivo de transferencia, que se descarga desde el backend (`generarTransferencia`).

## 6. Seguridad
- Validación de parámetros en backend.
- Los archivos generados se almacenan en un directorio seguro y se exponen sólo para descarga autenticada.

## 7. Consideraciones
- El frontend asume que las cuentas y bancos pueden ser precargados o consultados vía API.
- El archivo de transferencia se genera en el servidor y se expone vía URL para descarga.
- El proceso de generación de archivo es atómico y seguro.

## 8. Extensibilidad
- Se pueden agregar nuevos tipos de documentos o formatos de archivo modificando el stored procedure `sp_generar_transferencia`.

---


## Casos de Uso

# Casos de Uso - TrDocumentos

**Categoría:** Form

## Caso de Uso 1: Consulta de Cheques por Fecha y Cuenta

**Descripción:** El usuario desea consultar todos los cheques emitidos en una fecha específica para una cuenta determinada.

**Precondiciones:**
El usuario tiene acceso al sistema y existen cheques emitidos en la fecha y cuenta seleccionadas.

**Pasos a seguir:**
1. Ingresar a la página de Transferencia de Documentos.
2. Seleccionar la fecha de elaboración deseada.
3. Seleccionar la cuenta correspondiente.
4. Seleccionar 'Cheques' como tipo de documento.
5. Hacer clic en 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los cheques emitidos en la fecha y cuenta seleccionadas.

**Datos de prueba:**
fecha_elaboracion: '2024-06-01', cuenta: 1, tipo_doc: 'C'

---

## Caso de Uso 2: Generación de Archivo de Transferencia Electrónica (Bco. Pagador)

**Descripción:** El usuario genera el archivo de transferencia electrónica para pagos a través del banco pagador.

**Precondiciones:**
Existen documentos tipo 'Elec. Bco. Pagador' para la fecha y cuenta seleccionadas.

**Pasos a seguir:**
1. Seleccionar la fecha y cuenta.
2. Seleccionar 'Elec. Bco. Pagador' como tipo de documento.
3. Hacer clic en 'Buscar'.
4. Revisar la lista de documentos.
5. Hacer clic en 'Generar Archivo de Transferencia'.

**Resultado esperado:**
Se genera un archivo de texto descargable con los datos de transferencia electrónica.

**Datos de prueba:**
fecha_elaboracion: '2024-06-01', cuenta: 1, tipo_doc: 'P'

---

## Caso de Uso 3: Consulta de Transferencias a Otros Bancos

**Descripción:** El usuario consulta transferencias electrónicas realizadas a bancos distintos al pagador.

**Precondiciones:**
Existen transferencias electrónicas a otros bancos para la fecha y cuenta seleccionadas.

**Pasos a seguir:**
1. Seleccionar la fecha y cuenta.
2. Seleccionar 'Elec. Otros Bancos' como tipo de documento.
3. Hacer clic en 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con las transferencias electrónicas a otros bancos.

**Datos de prueba:**
fecha_elaboracion: '2024-06-01', cuenta: 1, tipo_doc: 'O'

---



## Casos de Prueba

# Casos de Prueba: TrDocumentos

## Caso 1: Consulta de Cheques Existentes
- **Entrada**: fecha_elaboracion = '2024-06-01', cuenta = 1, tipo_doc = 'C'
- **Acción**: Buscar documentos
- **Esperado**: Se listan todos los cheques emitidos ese día para la cuenta seleccionada.

## Caso 2: Generación de Archivo de Transferencia (Bco. Pagador)
- **Entrada**: fecha_elaboracion = '2024-06-01', cuenta = 1, tipo_doc = 'P'
- **Acción**: Buscar y luego generar archivo
- **Esperado**: Se genera archivo .txt descargable con los datos de transferencia electrónica.

## Caso 3: Consulta sin Resultados
- **Entrada**: fecha_elaboracion = '2024-01-01', cuenta = 1, tipo_doc = 'O'
- **Acción**: Buscar documentos
- **Esperado**: Se muestra mensaje de 'No se encontraron documentos para los criterios seleccionados.'

## Caso 4: Error al Generar Archivo (sin cuenta de transferencia)
- **Entrada**: cuenta sin cuenta de transferencia asociada
- **Acción**: Intentar generar archivo
- **Esperado**: Se muestra mensaje de error 'No se encontró la cuenta de transferencia'.

## Caso 5: Validación de Parámetros
- **Entrada**: Campos vacíos o inválidos
- **Acción**: Buscar o generar archivo
- **Esperado**: El sistema rechaza la operación y muestra mensaje de error.


