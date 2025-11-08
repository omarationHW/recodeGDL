# Menu - Menú Principal del Sistema

## Propósito Administrativo
Módulo principal de navegación del sistema de cementerios que controla el acceso a todas las funcionalidades, gestiona la seguridad de usuarios y organiza las opciones disponibles según permisos.

## Funcionalidad Principal
Proporciona el punto de entrada único al sistema, validando credenciales de usuario, mostrando opciones disponibles según permisos, y permitiendo navegación organizada a todos los módulos del sistema.

## Proceso de Negocio

### ¿Qué hace?
Gestiona el acceso y navegación del sistema:
- Valida usuario y contraseña contra Active Directory
- Carga perfil y permisos del usuario
- Presenta menú organizado por categorías funcionales
- Controla acceso a módulos según autorizaciones
- Muestra información del usuario conectado
- Proporciona acceso a cambio de contraseña
- Permite configuración de impresora
- Cierra sesión de forma segura

### ¿Para qué sirve?
Centraliza el control de acceso al sistema:
- Seguridad mediante autenticación de usuarios
- Organización lógica de funcionalidades
- Control de permisos por usuario
- Navegación intuitiva entre módulos
- Registro de usuarios activos en el sistema

### ¿Cómo lo hace?
1. Al iniciar, valida conexión a base de datos
2. Recupera credenciales del usuario desde Active Directory
3. Valida usuario contra tabla ta_usuarios
4. Carga nivel de usuario y recaudadora asignada
5. Consulta autorizaciones especiales del usuario
6. Presenta menú principal organizado en 4 páginas:
   - **Página 1 - Catálogos**: Altas, modificaciones, consultas
   - **Página 2 - Operaciones**: Pagos, liquidaciones, movimientos
   - **Página 3 - Reportes**: Consultas y reportes por panteón
   - **Página 4 - Configuración**: Títulos, traslados, descuentos, cambio de contraseña, salir
7. Cada opción abre el módulo correspondiente
8. Mantiene solo una ventana activa (MDI)
9. Muestra fecha actual y usuario conectado

### ¿Qué necesita para funcionar?
- Conexión activa a base de datos
- Usuario válido en sistema de autenticación
- Tabla ta_usuarios configurada
- Tabla ta_autoriza para permisos especiales
- Archivo de versión del ejecutable

## Datos y Tablas

### Tabla Principal
**ta_usuarios** - Catálogo de usuarios del sistema
Contiene: id_usuario, usuario, nombre, estado, id_rec (recaudadora), nivel

### Tablas Relacionadas
- **ta_autoriza** - Autorizaciones especiales por usuario y módulo
- **ta_recaudadoras** - Recaudadoras disponibles
- **Módulo Autoriza** - Componente que carga autorizaciones

### Stored Procedures (SP)
Ninguno (solo consultas directas)

### Tablas que Afecta
**Solo Consulta:**
- ta_usuarios (validación y carga de perfil)
- ta_autoriza (permisos especiales)

## Impacto y Repercusiones

### Repercusiones Operativas
- Control de acceso unificado
- Navegación estándar para todos los usuarios
- Cierre seguro del sistema
- Actualización automática de versiones

### Repercusiones Financieras
- Control de quién realiza operaciones financieras
- Restricción de módulos según nivel de usuario
- Auditoría de accesos al sistema

### Repercusiones Administrativas
- Cumplimiento de políticas de seguridad
- Trazabilidad de usuarios conectados
- Control de versiones del sistema
- Organización funcional del sistema

## Validaciones y Controles
- Verifica autenticación contra Active Directory
- Valida que el usuario exista en ta_usuarios
- Impide acceso sin autenticación válida
- Verifica conexión a base de datos antes de mostrar menú
- Carga automáticamente tabla de autorizaciones
- Solo permite una instancia del sistema por usuario
- Cierra automáticamente si no hay conexión

## Casos de Uso
1. **Inicio de sesión**: Usuario ingresa al sistema y accede a módulos autorizados
2. **Navegación entre módulos**: Usuario selecciona opciones del menú
3. **Cambio de contraseña**: Usuario actualiza su contraseña de acceso
4. **Consulta rápida**: Acceso directo a módulos de consulta
5. **Configuración de impresora**: Usuario configura impresora antes de imprimir reportes
6. **Cierre de sesión**: Usuario sale del sistema de forma segura

## Usuarios del Sistema
- **Cajeros**: Acceso a módulos de pagos y consultas básicas
- **Supervisores**: Acceso a módulos de modificación y reportes
- **Administradores**: Acceso completo a todos los módulos
- **Contabilidad**: Acceso a reportes y consultas financieras
- **Personal de Títulos**: Acceso a módulos de títulos y duplicados

## Relaciones con Otros Módulos
**Menú da acceso a:**

**Catálogos:**
- ABCementer (Alta por ubicación)
- ABCFolio (Modificación por folio)
- ConsultaFol (Consulta por folio)
- MultipleRCM (Consulta múltiple por ubicación)
- MultipleNombre (Consulta múltiple por nombre)
- MultipleFecha (Consulta por fecha de pago)

**Operaciones:**
- ABCPagos (Registro de pagos)
- Liquidaciones (Liquidación de adeudos)
- List_Mov (Listado de movimientos)

**Reportes:**
- ConsultaGuad (Guadalajara)
- ConsultaMezq (Mezquitán)
- ConsultaSAndres (San Andrés)
- ConsultaJardin (Jardín)
- Rep_a_Cobrar (Reporte de cuentas por cobrar)
- Rep_Bon (Reporte de bonificaciones)

**Configuración:**
- Titulos (Impresión de títulos)
- Duplicados (Duplicados de títulos)
- TrasladoFolSin (Traslados)
- Descuentos (Gestión de descuentos)
- Bonificaciones (Gestión de bonificaciones)
- sfrm_chgpass (Cambio de contraseña)

## Estructura del Menú

### LookOutPage1 - Catálogos
- Alta por Ubicación
- Modificación por Folio
- Consultas
- Descuentos
- Salir

### LookOutPage2 - Operaciones
- Aplicar Pagos
- Cuentas por Cobrar
- Listado de Movimientos

### LookOutPage3 - Reportes
- Consultas por Panteón (Guadalajara, Mezquitán, San Andrés, Jardín)
- Reporte de Bonificaciones

### LookOutPage4 - Configuración
- Imprimir Títulos
- Duplicados
- Traslados
- Cambiar Contraseña
- Configurar Impresora
- Salir del Sistema
