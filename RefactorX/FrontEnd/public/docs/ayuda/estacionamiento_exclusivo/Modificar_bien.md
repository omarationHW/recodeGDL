# Modificación de Folios (Versión Mejorada)

## Propósito Administrativo
Modificar folios de apremios con interfaz mejorada y validaciones reforzadas, incorporando verificación automática de folios sin adeudo, controles más estrictos y mejor experiencia de usuario en el proceso de actualización de requerimientos.

## Funcionalidad Principal
Este módulo es una versión mejorada del sistema de modificación individual de folios, que incluye validaciones automáticas de folios sin adeudo, permisos granulares por botón, controles reforzados de fechas y mejor organización de la interfaz para facilitar las modificaciones.

## Proceso de Negocio

### ¿Qué hace?
Permite modificar folios individuales con una interfaz reorganizada en paneles por tipo de operación, validando automáticamente la existencia de adeudos antes de permitir modificaciones, controlando permisos específicos por tipo de acción, y manteniendo el historial completo de cambios.

### ¿Para qué sirve?
- Modificar folios con validaciones automáticas reforzadas
- Verificar automáticamente la existencia de adeudos
- Controlar permisos específicos por tipo de modificación
- Facilitar la modificación con interfaz organizada por paneles
- Prevenir modificaciones en folios sin adeudo
- Mantener trazabilidad completa con historial
- Mejorar la experiencia del usuario en modificaciones

### ¿Cómo lo hace?
1. El usuario selecciona tipo de aplicación (Mercados, Aseo, Públicos, Exclusivos, Infracciones, Cementerios)
2. Ingresa folio y oficina recaudadora
3. El sistema busca el folio y verifica su vigencia
4. Ejecuta automáticamente el SP de verificación de adeudos
5. Si el folio no tiene adeudo, ofrece cancelarlo
6. Si tiene adeudo, muestra la información completa
7. Presenta paneles organizados por tipo de modificación:
   - Panel Ejecutor: Asignación y fechas de entrega
   - Panel Citatorio: Fecha y hora de citatorio
   - Panel Practicado: Fecha, hora y estado de practicado
   - Panel Multa: Porcentaje de multa a cobrar
   - Panel Remate: Secuestro y remate
   - Panel Pagos: Datos completos de pago
   - Panel Cancelación: Cancelación del folio
8. Cada panel se activa solo si cumple condiciones:
   - Ejecutor: Si clave_practicado='S' (sin practicar)
   - Citatorio: Si tiene ejecutor asignado
   - Practicado: Si tiene ejecutor asignado
   - Multa: Si está practicado
   - Pagos: Si está practicado
   - Remate: Si está practicado
   - Cancelación: Siempre disponible
9. Valida permisos específicos por botón de modificación
10. Valida gastos contra tabla vigente según fecha
11. Guarda historial completo antes de modificar
12. Aplica los cambios con transacción

### ¿Qué necesita para funcionar?
- Usuario con permisos específicos por tipo de modificación
- Folio válido y vigente
- Stored procedure de verificación de adeudos
- Tabla de permisos por botón actualizada
- Tabla de gastos vigente
- Catálogos de claves completos
- Validación automática habilitada

## Datos y Tablas

### Tabla Principal
- **ta_15_apremios**: Folios a modificar

### Tablas Relacionadas
- **ta_15_historia**: Historial de modificaciones
- **ta_15_ejecutores**: Validación de ejecutores
- **ta_12_gastos**: Validación de gastos por fecha
- **ta_11_locales**: Datos de locales en mercados
- **ta_11_adeudo_local**: Verificación de adeudos en mercados
- **ta_16_contratos_aseo**: Contratos de aseo
- **ta_16_adeudos_aseo**: Verificación de adeudos en aseo
- **dbestacion::pubmain**: Estacionamientos públicos
- **dbestacion::ex_contrato**: Estacionamientos exclusivos
- **ta_14_infracciones_placas**: Infracciones
- **ta_13_cementerios**: Cementerios
- **ta_15_permisos_botones**: Control de permisos por usuario y acción

### Stored Procedures (SP)
- **sp_verifica_folios_sin_adeudo**: Verifica automáticamente si el folio tiene adeudos
  - Parámetros: folio, módulo, oficina, opción de cancelar
  - Retorna: cantidad de folios sin adeudo y observaciones
  - Acción opcional: Cancela el folio si no tiene adeudo y se confirma

### Tablas que Afecta
- **INSERT en ta_15_historia**: Guarda el estado anterior
- **UPDATE en ta_15_apremios**: Actualiza el folio según la modificación
- Los campos modificados dependen del panel utilizado

## Impacto y Repercusiones

### Repercusiones Operativas
- Previene modificaciones en folios sin adeudo
- Mejora significativamente la experiencia del usuario
- Reduce errores con validaciones automáticas
- Agiliza el proceso con interfaz organizada
- Controla mejor los permisos por acción

### Repercusiones Financieras
- Evita gastos de gestión en folios sin adeudo
- Mejora la validación de importes de gastos
- Garantiza aplicación correcta de normativa
- Mantiene integridad de datos financieros

### Repercusiones Administrativas
- Refuerza controles y validaciones
- Mejora la trazabilidad con historial
- Facilita auditorías con mejor documentación
- Apoya permisos granulares por función
- Previene modificaciones indebidas

## Validaciones y Controles
- Ejecuta automáticamente SP de verificación de adeudos
- Ofrece cancelar folios sin adeudo antes de modificar
- Valida permisos específicos por cada botón de modificación
- Controla que modificaciones sigan la secuencia lógica del proceso
- Para Ejecutor: Valida que clave_practicado='S' y ejecutor válido
- Para Citatorio: Requiere ejecutor asignado
- Para Practicado: Requiere ejecutor, valida gastos contra tabla
- Para Multa: Requiere que esté practicado
- Para Pagos: Valida datos completos y que esté practicado
- Para Remate: Requiere que esté practicado
- Valida fechas lógicas y no futuras
- Para entrega2: requiere checkbox y valida fecha > entrega1
- Usa transacciones para integridad
- Guarda historial antes de modificar

## Casos de Uso
1. **Supervisor**: Intenta modificar folio y sistema detecta que no tiene adeudo
2. **Jefe de Ejecutores**: Asigna ejecutor a folio verificado
3. **Ejecutor**: Actualiza fecha de practicado validando gastos automáticamente
4. **Coordinador**: Modifica folio con permisos específicos para cada acción
5. **Auditor**: Verifica que modificaciones sigan la secuencia correcta del proceso

## Usuarios del Sistema
- Todos los usuarios del sistema anterior, con permisos más granulares:
  - Botón 11: Puede asignar ejecutor
  - Botón 12: Puede registrar citatorio
  - Botón 13: Puede registrar practicado
  - Botón 16: Puede poner en remate
- Supervisores y directores: Permisos completos

## Relaciones con Otros Módulos
- **Modifcar**: Versión anterior de modificación
- **Modif_Masiva**: Modificación masiva
- **ConsultaReg**: Consulta del folio
- **Cons_his**: Consulta del historial
- **AutorizaDes**: Autorización para acciones especiales
- **Ejecutores**: Validación de ejecutores
- **Recuperacion**: Registro de pagos
