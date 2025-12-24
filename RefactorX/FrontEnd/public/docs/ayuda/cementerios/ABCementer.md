# ABCementer - Alta, Baja y Cambio de Registros de Cementerio

## Propósito Administrativo
Módulo para gestionar el alta, modificación y baja de espacios funerarios (fosas, urnas y gavetas) en los diferentes panteones municipales de Guadalajara.

## Funcionalidad Principal
Permite registrar nuevos espacios funerarios en el sistema, capturando la información del concesionario (propietario o beneficiario del espacio), la ubicación física del espacio dentro del panteón, y los datos de pago inicial.

## Proceso de Negocio

### ¿Qué hace?
Administra el catálogo completo de espacios funerarios en los cementerios municipales, permitiendo:
- Registrar nuevos espacios cuando se venden concesiones
- Actualizar información de espacios existentes
- Dar de baja espacios (marcándolos como inactivos)
- Asociar información adicional del concesionario (RFC, CURP, teléfono, clave IFE)

### ¿Para qué sirve?
Mantiene el inventario actualizado de todos los espacios funerarios disponibles y ocupados en los panteones, garantizando:
- Control de ocupación de espacios
- Registro legal de concesionarios
- Trazabilidad de cambios en la propiedad
- Base para el cobro de derechos de mantenimiento

### ¿Cómo lo hace?
1. El operador selecciona el cementerio y captura la ubicación exacta (clase, sección, línea, fosa con sus variantes alfabéticas)
2. Verifica que el espacio no esté ya registrado en el sistema
3. Captura datos del concesionario (nombre completo, domicilio, exterior, interior, colonia)
4. Indica el tipo de espacio (Fosa, Urna o Gaveta) y metros cuadrados
5. Registra el año hasta el cual está pagado el mantenimiento
6. Opcionalmente captura datos fiscales y de contacto
7. El sistema genera automáticamente el folio de control RCM (Registro de Cementerios)
8. Crea los adeudos correspondientes de mantenimiento anual

### ¿Qué necesita para funcionar?
- Selección previa del cementerio (Guadalajara, Mezquitán, San Andrés, Jardín, etc.)
- Conocimiento de la ubicación física exacta del espacio
- Datos completos del concesionario
- Último año pagado de mantenimiento
- Permisos de usuario para realizar altas, bajas o cambios

## Datos y Tablas

### Tabla Principal
**ta_13_datosrcm** - Registro maestro de espacios funerarios
Contiene: folio RCM, cementerio, clase, sección, línea, fosa (todas con variantes alfanuméricas), año pagado, metros, nombre, domicilio, tipo (F/U/G), vigencia

### Tablas Relacionadas
- **ta_13_datosrcmadic** - Información adicional del concesionario (RFC, CURP, teléfono, clave IFE)
- **ta_13_adeudosrcm** - Adeudos de mantenimiento generados para el espacio
- **ta_historico** - Histórico de cambios en los registros

### Stored Procedures (SP)
- **StrdPrcABC** - Procedimiento que:
  - Par_control: Folio RCM del registro
  - Par_opc: 1=Alta de adeudos iniciales, 2=Baja de adeudos, 3=Actualización de adeudos
  - Par_usu: Usuario que realiza la operación
  - Genera automáticamente los adeudos anuales desde el último año pagado hasta el actual

- **StrdPrcHis** - Procedimiento para grabar histórico de cambios
  - Par_control: Folio RCM
  - Guarda snapshot del registro antes de modificarlo

### Tablas que Afecta
**Inserta:**
- ta_13_datosrcm (alta de nuevo espacio)
- ta_13_datosrcmadic (información fiscal del concesionario)
- ta_13_adeudosrcm (adeudos iniciales de mantenimiento)

**Actualiza:**
- ta_13_datosrcm (modificación de datos del espacio)
- ta_13_datosrcmadic (actualización de datos fiscales)
- ta_13_adeudosrcm (recálculo de adeudos)

**Marca como Baja:**
- ta_13_datosrcm (campo vigencia="B")
- ta_13_adeudosrcm (baja de adeudos pendientes)

## Impacto y Repercusiones

### Repercusiones Operativas
- Base fundamental para todos los cobros de mantenimiento
- Permite ubicación física exacta de cada espacio
- Control de ocupación de panteones
- Histórico de cambios de propietarios

### Repercusiones Financieras
- Genera adeudos automáticos de mantenimiento anual
- Base para cálculo de recargos por mora
- Permite aplicar descuentos y bonificaciones
- Control de cuentas por cobrar del departamento

### Repercusiones Administrativas
- Registro legal de concesionarios
- Cumplimiento de normativa municipal
- Soporte para expedición de títulos de propiedad
- Base para estadísticas y reportes gerenciales

## Validaciones y Controles
- Verifica que clase esté entre 1 y 3 (Primera, Segunda, Tercera)
- Valida que todos los campos de ubicación tengan información
- Impide registrar espacios duplicados en el mismo cementerio
- Valida que el último año pagado no sea mayor al año actual más 1
- Valida que el último año pagado no sea menor a (año actual - 6)
- Requiere nombre y domicilio completo obligatorios
- Control de transacciones para garantizar integridad de datos
- Solo permite borrar espacios sin pagos registrados

## Casos de Uso
1. **Venta nueva de concesión**: Cuando una familia adquiere un espacio, se registra con datos del comprador y año de pago inicial
2. **Cambio de titular**: Se actualiza nombre y domicilio del nuevo concesionario
3. **Actualización de contacto**: Agregar o modificar RFC, CURP, teléfono del concesionario
4. **Corrección de ubicación**: Modificar datos de ubicación por error en captura original
5. **Baja por error**: Eliminar registros capturados incorrectamente (solo si no tienen pagos)

## Usuarios del Sistema
- **Personal de Ventanilla**: Captura de nuevas concesiones y actualización de datos
- **Cajeros**: Consultan para verificar existencia y datos del espacio
- **Administradores de Panteones**: Supervisión y corrección de registros
- **Contabilidad**: Verificación de cuentas por cobrar

## Relaciones con Otros Módulos
- **ABCFolio**: Modificación de registros existentes buscando por folio RCM
- **ABCPagos**: Aplica pagos de mantenimiento contra adeudos generados
- **Consulta por Folio**: Visualiza información completa del espacio
- **Consultas por Panteón**: Búsqueda de espacios en cementerios específicos
- **Liquidaciones**: Procesa pagos totales de adeudos acumulados
- **Títulos**: Imprime títulos de propiedad usando datos del registro
- **Traslados**: Cambia ubicación de restos entre espacios
