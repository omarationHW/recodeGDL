# Visor de Reportes

## Propósito Administrativo
Módulo de visualización e impresión de reportes generados en el sistema de Apremios, proporcionando una interfaz de navegación y control de documentos antes de su impresión final.

## Funcionalidad Principal
Este módulo es un visor de reportes que permite visualizar en pantalla los documentos generados por el sistema (requerimientos, listados, notificaciones, etc.) antes de imprimirlos, con controles de navegación, zoom y opciones de guardado.

## Proceso de Negocio

### ¿Qué hace?
Proporciona una ventana de vista previa de reportes con controles para navegar entre páginas, ajustar el zoom, guardar y cargar documentos, e imprimir el reporte final.

### ¿Para qué sirve?
- Visualizar reportes antes de imprimirlos
- Navegar entre páginas de documentos multipágina
- Ajustar el zoom para mejor visualización
- Guardar reportes generados para consulta posterior
- Cargar reportes previamente guardados
- Enviar a impresora el documento visualizado
- Reducir desperdicios de papel al verificar antes de imprimir
- Facilitar la revisión de documentos largos

### ¿Cómo lo hace?
1. El módulo es invocado cuando se genera un reporte desde otros módulos
2. Muestra el reporte en un componente de vista previa (frPreview)
3. Proporciona botones de control:
   - **Primera página**: Ir al inicio del documento
   - **Página anterior**: Retroceder una página
   - **Página siguiente**: Avanzar una página
   - **Última página**: Ir al final del documento
   - **Una página**: Ver una página a la vez
   - **Zoom 100%**: Vista al tamaño real
   - **Ajustar ancho**: Ajustar a lo ancho de la ventana
   - **Cargar**: Abrir un reporte guardado previamente
   - **Guardar**: Guardar el reporte actual en archivo
   - **Imprimir**: Enviar a impresora
   - **Cerrar**: Cerrar el visor
4. Permite al usuario revisar el documento completo
5. El usuario decide si imprime o cierra sin imprimir

### ¿Qué necesita para funcionar?
- Componente FastReport o similar instalado
- Reporte generado previamente por otro módulo
- Impresora configurada (para función de impresión)
- Permisos de escritura en disco (para guardar reportes)

## Datos y Tablas

### Tabla Principal
- **No aplica**: Este módulo no accede directamente a tablas de base de datos

### Tablas Relacionadas
- **No aplica**: Solo visualiza reportes generados por otros módulos

### Stored Procedures (SP)
- **No utiliza**: Es un módulo de interfaz de usuario únicamente

### Tablas que Afecta
- **Ninguna**: Es un módulo de solo lectura/visualización

## Impacto y Repercusiones

### Repercusiones Operativas
- Mejora la eficiencia al permitir revisar antes de imprimir
- Reduce errores al detectar problemas antes de la impresión
- Facilita el trabajo con documentos multipágina
- Permite archivar electrónicamente los reportes generados
- Optimiza el uso de papel al evitar impresiones innecesarias

### Repercusiones Financieras
- Reduce costos de papel e impresión
- Minimiza desperdicios por errores de impresión
- Facilita auditorías al poder guardar reportes históricos
- No tiene impacto directo en recaudación o cobro

### Repercusiones Administrativas
- Facilita la revisión de documentos antes de su emisión oficial
- Permite compartir reportes en formato electrónico
- Agiliza la consulta de documentos al poder guardarlos
- Mejora la calidad de los documentos impresos
- Reduce reclamos por documentos mal impresos

## Validaciones y Controles
- Verificación de que existe un reporte cargado antes de permitir operaciones
- Control de navegación solo en rangos válidos de páginas
- Verificación de impresora disponible antes de imprimir
- Validación de permisos de escritura al guardar archivos
- Confirmación de operaciones críticas (imprimir, guardar)

## Casos de Uso

1. **Visualizar requerimiento antes de imprimir**: Usuario genera un requerimiento de pago, el sistema abre este visor mostrando el documento, el usuario lo revisa en pantalla, ajusta el zoom si es necesario, verifica que todo esté correcto y luego presiona imprimir.

2. **Revisar listado multipágina**: Usuario genera un listado de 50 páginas, usa los controles de navegación para revisar diferentes secciones, verifica los totales en la última página, y decide si imprime todo o solo guarda electrónicamente.

3. **Guardar reporte para envío electrónico**: Usuario genera un reporte, lo visualiza, presiona guardar, lo almacena en formato electrónico, y luego lo envía por correo a otra área sin necesidad de imprimir.

4. **Consultar reporte guardado**: Usuario carga un reporte generado anteriormente, lo revisa en pantalla para responder una consulta, sin necesidad de buscar la versión impresa.

## Usuarios del Sistema
- **Ejecutores fiscales**: Para visualizar requerimientos antes de entregarlos
- **Supervisores**: Para revisar listados y reportes gerenciales
- **Personal administrativo**: Para verificar documentos antes de impresión masiva
- **Auditoría**: Para consultar reportes históricos guardados
- **Jefes de área**: Para revisar informes de gestión

## Relaciones con Otros Módulos

### Invocado por:
- **Requerimientos.md**: Para visualizar requerimientos generados
- **Notificaciones.md**: Para revisar notificaciones antes de imprimir
- **CartaInvitacion.md**: Para ver cartas de invitación
- **Listados.md**: Para visualizar listados de trabajo
- **Recuperacion.md**: Para ver reportes de recuperación
- **Prenomina.md**: Para revisar prenóminas generadas
- Todos los módulos de reportes (RprtXXX, RptXXX)

### Interacción:
- **Recibe**: Objeto de reporte generado por el módulo invocador
- **Devuelve**: Confirmación de si se imprimió o se canceló

### Dependencias:
- Librería FastReport o componente de reportes compatible
- Drivers de impresora del sistema operativo
- Sistema de archivos para guardar/cargar reportes

---

**Nota**: Este es un módulo utilitario crítico para el sistema, ya que proporciona la interfaz de visualización para todos los reportes generados. Aunque no interactúa directamente con la base de datos, es esencial para la operación eficiente y profesional del sistema de Apremios.
