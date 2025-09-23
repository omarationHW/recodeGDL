# Documentación Técnica: Migración de Formulario Gen_ArcAltas (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la generación de archivos de texto con los folios de alta de vehículos para un periodo seleccionado. El proceso incluye:
- Consulta del último periodo de altas registrado.
- Selección de un nuevo periodo de altas.
- Ejecución de un proceso de "remesa" que agrupa los folios del periodo.
- Conteo de folios generados.
- Exportación de los datos a un archivo de texto descargable.

## 2. Arquitectura
- **Backend:** Laravel API, con endpoint único `/api/execute` que recibe un objeto `eRequest` con la acción y parámetros.
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL, con stored procedures para encapsular la lógica de negocio.

## 3. API Unificada
### Endpoint
`POST /api/execute`

#### Entrada
```json
{
  "eRequest": {
    "action": "get_periodos|ejecutar_remesa|contar_folios|generar_archivo",
    "params": { ... }
  }
}
```

#### Salida
```json
{
  "eResponse": {
    "success": true|false,
    "data": { ... },
    "message": "..."
  }
}
```

### Acciones soportadas
- `get_periodos`: Devuelve el último periodo de altas.
- `ejecutar_remesa`: Ejecuta el proceso de remesa para el periodo seleccionado.
- `contar_folios`: Devuelve el número de folios generados para una remesa.
- `generar_archivo`: Genera el archivo de texto y devuelve la URL de descarga.

## 4. Stored Procedures
- **sp14_remesa:** Proceso principal de generación de remesa.
- **contar_folios_remesa:** Cuenta los folios de una remesa.
- **get_periodo_altas:** Devuelve el último periodo de altas.
- **generar_archivo_remesa:** Devuelve los datos para el archivo de texto.

## 5. Frontend (Vue.js)
- Página independiente con navegación breadcrumb.
- Selección de fechas para el nuevo periodo.
- Botones: Ejecutar, Generar Archivo, Cancelar.
- Visualización de folios y remesa generada.
- Descarga del archivo generado.

## 6. Seguridad
- El endpoint requiere autenticación (middleware Laravel, no mostrado aquí).
- Validación de parámetros en backend.
- Los archivos generados se almacenan temporalmente y sólo son accesibles por usuarios autenticados.

## 7. Consideraciones
- El proceso de generación de remesa debe ser atómico (transacción).
- El archivo de texto se genera sólo si existen folios para la remesa.
- El nombre del archivo incluye el identificador de remesa y la fecha/hora.

## 8. Flujo de Usuario
1. El usuario accede a la página de generación de altas.
2. Visualiza el último periodo registrado.
3. Selecciona el nuevo periodo (inicio y fin).
4. Ejecuta la remesa.
5. Si hay folios, puede generar y descargar el archivo de texto.

## 9. Errores y Mensajes
- Si no hay folios, se muestra mensaje informativo.
- Si ocurre un error en el proceso, se muestra el mensaje devuelto por el backend.

## 10. Pruebas
- Ver sección de Casos de Uso y Casos de Prueba.
