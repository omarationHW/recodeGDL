# Búsqueda de Actividades

## Descripción General

### ¿Qué hace este módulo?
Este módulo proporciona una interfaz de búsqueda y selección de actividades económicas. Permite buscar actividades por texto libre, filtrar por giro SCIAN, visualizar los resultados en una cuadrícula y seleccionar la actividad deseada para su uso en otros módulos.

### ¿Para qué sirve en el proceso administrativo?
Sirve como un diálogo de búsqueda auxiliar que facilita:
- Encontrar actividades específicas cuando hay muchas opciones
- Filtrar actividades por giro SCIAN
- Visualizar la descripción completa de cada actividad
- Seleccionar la actividad correcta al registrar o modificar licencias
- Evitar errores de captura al proporcionar búsqueda con coincidencia parcial

### ¿Quiénes lo utilizan?
- Personal de ventanilla al registrar solicitudes
- Personal del área de Licencias al capturar trámites
- Cualquier usuario que necesite seleccionar una actividad en el sistema
- El módulo es invocado automáticamente por otros formularios

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?
1. El módulo se abre como ventana modal desde otro formulario (registro de solicitud, modificación de licencia, etc.)
2. El sistema carga el catálogo de actividades vigentes
3. Si hay un giro preseleccionado, filtra las actividades de ese giro específico
4. El usuario puede:
   - Escribir texto en el campo de búsqueda para filtrar por descripción
   - Navegar por las actividades en el grid
   - Hacer doble clic en una actividad para seleccionarla
   - O presionar el botón "Aceptar" después de seleccionar
5. Al seleccionar una actividad:
   - Se cierra el formulario automáticamente
   - Se retorna el ID y descripción de la actividad seleccionada
   - El formulario invocador recibe estos datos

### ¿Qué información requiere el usuario?
- **Texto de búsqueda** (opcional): Palabra o frase para filtrar actividades
- **Giro SCIAN** (opcional, puede venir preseleccionado): Para filtrar solo actividades de un giro específico

### ¿Qué validaciones se realizan?
- Se verifica que existan actividades en el catálogo
- Solo se muestran actividades vigentes (vigente='V')
- Si hay giro seleccionado, solo muestra actividades de ese giro
- La búsqueda filtra en tiempo real mientras el usuario escribe

### ¿Qué documentos genera?
Este módulo no genera documentos. Es una herramienta de búsqueda y selección auxiliar.

## Tablas de Base de Datos

### Tabla Principal
**c_actividades**: Catálogo de actividades económicas
- Se utiliza para mostrar las actividades disponibles
- Se consulta con filtro de vigencia y giro

### Tablas Relacionadas

#### Tablas que consulta:
- **c_actividades**:
  - Lee todas las actividades vigentes
  - Filtra por id_giro si está especificado
  - Filtra por texto en el campo descripción

#### Tablas que modifica:
- Ninguna. Este es un módulo de solo lectura/consulta.

## Stored Procedures
Este módulo no consume stored procedures.

## Impacto y Repercusiones

### ¿Qué registros afecta?
No afecta directamente ningún registro. Solo facilita la búsqueda y selección de actividades existentes.

### ¿Qué cambios de estado provoca?
Ninguno. Es un módulo auxiliar de consulta.

### ¿Qué documentos/reportes genera?
No genera documentos.

### ¿Qué validaciones de negocio aplica?
- Solo muestra actividades vigentes
- Respeta el filtro de giro si fue especificado
- Permite cancelar sin seleccionar nada

## Flujo de Trabajo

### Descripción del flujo completo del proceso

```
1. Inicio (invocado por otro módulo)
2. ¿Hay giro preseleccionado?
   - Sí: Cargar solo actividades del giro
   - No: Cargar todas las actividades vigentes
3. Mostrar formulario modal con grid de actividades
4. Usuario escribe en búsqueda
5. ¿Hay texto de búsqueda?
   - Sí: Filtrar actividades que contengan el texto
   - No: Mostrar todas
6. Sistema actualiza grid en tiempo real
7. Usuario selecciona una actividad del grid
8. ¿Usuario confirmó selección?
   - Doble clic en grid: Sí
   - Botón Aceptar: Sí
   - Botón Cancelar o cerrar: No
9. Si seleccionó:
   - Guardar id_actividad y descripción seleccionados
   - Cerrar formulario
   - Retornar valores al formulario invocador
10. Si canceló:
    - Retornar valores vacíos/nulos
11. Fin
```

## Notas Importantes

### Consideraciones especiales
- **Formulario modal**: Bloquea la interacción con otras ventanas hasta cerrarse
- **Auto-destrucción**: Se libera de memoria automáticamente al cerrarse (action:=cafree)
- **Búsqueda en tiempo real**: Filtra automáticamente mientras se escribe
- **Integración**: Diseñado para ser llamado desde múltiples módulos
- **Doble selección**: Permite seleccionar con doble clic o con botón Aceptar

### Restricciones
- Solo muestra actividades vigentes (no canceladas)
- Si se especificó un giro, no se pueden ver actividades de otros giros
- No permite agregar nuevas actividades desde este formulario
- No permite modificar la descripción de actividades

### Permisos necesarios
- Este formulario hereda los permisos del formulario que lo invoca
- No tiene validaciones propias de permisos
- Cualquier usuario que pueda acceder al formulario invocador puede usar esta búsqueda

### Mejores prácticas de uso
1. **Búsqueda efectiva**: Usar palabras clave descriptivas
2. **Revisión**: Leer la descripción completa antes de seleccionar
3. **Navegación**: Usar teclas de flechas para navegar por las opciones
4. **Confirmación**: Verificar que la actividad seleccionada sea la correcta
5. **Cancelación**: Si no encuentra la actividad, cancelar y reportar al supervisor

### Integración con otros módulos
Este formulario es invocado típicamente por:
- **Registro de solicitudes (regsolicfrm)**: Al seleccionar actividad para nueva licencia
- **Modificación de licencias (modlicfrm)**: Al cambiar la actividad de una licencia
- **Modificación de trámites (modtramitefrm)**: Al actualizar actividad en trámite
- Cualquier otro módulo que necesite buscar y seleccionar actividades

### Formato de retorno de datos
Cuando se selecciona una actividad, el formulario retorna:
- `id_actividad`: Identificador numérico de la actividad (campo oculto)
- `descripcion`: Texto descriptivo de la actividad
- Estos valores son capturados por el formulario invocador para su procesamiento

### Rendimiento
- La búsqueda es eficiente ya que se basa en consultas SQL con filtros
- El filtrado en tiempo real puede ser lento si hay muchas actividades
- Se recomienda mantener el catálogo de actividades actualizado y sin registros obsoletos
