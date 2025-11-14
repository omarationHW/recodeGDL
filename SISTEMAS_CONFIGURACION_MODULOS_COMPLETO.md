# SISTEMAS Y CONFIGURACIÓN DE MÓDULOS - recodeGDL

**Proyecto:** Sistema Municipal de Guadalajara - recodeGDL
**Municipio:** Guadalajara (ID: 39)
**Fecha de documentación:** 13 de noviembre de 2025
**Versión:** 1.0
**Arquitectura:** Vue.js 3 + Laravel 12 + PostgreSQL 16

---

## TABLA DE CONTENIDOS

1. [Introducción](#1-introducción)
2. [Arquitectura General del Sistema](#2-arquitectura-general-del-sistema)
3. [Sistema de Configuración Global](#3-sistema-de-configuración-global)
4. [Módulo: Aseo Contratado](#4-módulo-aseo-contratado)
5. [Módulo: Cementerios](#5-módulo-cementerios)
6. [Módulo: Estacionamiento Exclusivo](#6-módulo-estacionamiento-exclusivo)
7. [Módulo: Estacionamiento Público](#7-módulo-estacionamiento-público)
8. [Módulo: Mercados](#8-módulo-mercados)
9. [Módulo: Multas y Reglamentos](#9-módulo-multas-y-reglamentos)
10. [Módulo: Otras Obligaciones](#10-módulo-otras-obligaciones)
11. [Módulo: Padrón de Licencias](#11-módulo-padrón-de-licencias)
12. [Integración entre Módulos](#12-integración-entre-módulos)
13. [Guía de Parametrización](#13-guía-de-parametrización)
14. [Anexos](#14-anexos)

---

## 1. INTRODUCCIÓN

### 1.1 Propósito del Documento

Este documento describe de manera integral los sistemas y aplicaciones que conforman el proyecto recodeGDL, el cual representa la modernización completa del sistema de gestión municipal del Municipio de Guadalajara. El objetivo es proporcionar una visión clara de cómo cada módulo está configurado, parametrizado y cómo interactúa con el resto del ecosistema.

### 1.2 Alcance

El sistema recodeGDL abarca ocho subsistemas principales que gestionan diferentes aspectos de los ingresos y servicios municipales. Cada subsistema opera de manera independiente pero comparte una arquitectura común y se integra a través de tablas transversales y un sistema de API unificado.

### 1.3 Contexto del Proyecto

El proyecto recodeGDL surge de la necesidad de migrar el sistema legacy basado en Informix y AS/400 hacia una arquitectura moderna que permita mayor escalabilidad, mantenibilidad y una mejor experiencia de usuario. La migración se ha realizado manteniendo la lógica de negocio existente mediante stored procedures en PostgreSQL, mientras se moderniza completamente la interfaz de usuario con tecnologías web actuales.

### 1.4 Audiencia

Este documento está dirigido a:
- Desarrolladores que trabajen en el mantenimiento o expansión del sistema
- Administradores de sistemas responsables del despliegue
- Personal técnico del municipio que requiera entender la arquitectura
- Equipos de soporte que necesiten conocer la configuración de cada módulo

---

## 2. ARQUITECTURA GENERAL DEL SISTEMA

### 2.1 Visión General

El sistema recodeGDL está construido siguiendo una arquitectura de tres capas claramente definidas: Frontend en Vue.js 3, Backend en Laravel 12, y Base de Datos en PostgreSQL 16. Esta arquitectura permite una separación clara de responsabilidades y facilita el mantenimiento independiente de cada capa.

**Componentes principales:**

- **Frontend (Vue.js 3):** Aplicación de página única que proporciona la interfaz de usuario para los ocho módulos del sistema. Utiliza Vue Router para la navegación y Axios para la comunicación con el backend.

- **Backend (Laravel 12):** API REST que actúa como intermediario entre el frontend y la base de datos. Implementa un controlador genérico que ejecuta stored procedures de manera dinámica.

- **Base de Datos (PostgreSQL 16):** Almacena toda la información del sistema distribuida en múltiples esquemas, uno por cada módulo. Contiene 6,558 tablas y 1,520 stored procedures que implementan la lógica de negocio.

### 2.2 Patrón de Comunicación

El sistema implementa un patrón de comunicación unificado donde todas las operaciones se realizan a través de un único endpoint genérico. Este diseño simplifica enormemente el mantenimiento y permite agregar nuevas funcionalidades sin modificar el código del backend.

Cuando un usuario interactúa con cualquier módulo del sistema, el flujo de comunicación es el siguiente:

1. El componente Vue invoca una función del composable `useApi`
2. El composable construye una petición estandarizada con el nombre del stored procedure y sus parámetros
3. La petición se envía al endpoint `/api/generic` del backend Laravel
4. El backend ejecuta el stored procedure correspondiente en PostgreSQL
5. Los resultados se devuelven al frontend en formato JSON estandarizado
6. El componente Vue procesa y presenta los datos al usuario

Este patrón elimina la necesidad de crear controladores y rutas específicas para cada operación, reduciendo significativamente la complejidad del código y facilitando la adición de nuevas funcionalidades.

### 2.3 Estándares y Convenciones

Todos los módulos del sistema siguen convenciones uniformes que garantizan consistencia y facilitan la comprensión del código:

**Nomenclatura de componentes Vue:**
- Los componentes administrativos (ABCs) utilizan el prefijo `ABC_` seguido del nombre de la entidad
- Los formularios de consulta terminan con el sufijo `frm`
- Los reportes utilizan el prefijo `Rep_`
- Ejemplos: `ABC_Empresas.vue`, `ConsultaUsuariofrm.vue`, `Rep_Contratos.vue`

**Nomenclatura de stored procedures:**
- Cada módulo define su propio patrón de nombres para los stored procedures
- Los procedimientos de listado suelen terminar en `_list` o `_cons`
- Los procedimientos de inserción terminan en `_ins` o `_create`
- Los procedimientos de actualización terminan en `_upd` o `_update`
- Los procedimientos de eliminación terminan en `_del` o `_delete`

**Estructura de carpetas:**
- Cada módulo tiene su carpeta en `RefactorX/FrontEnd/src/views/modules/[nombre_modulo]`
- Los stored procedures se organizan en `RefactorX/Base/[nombre_modulo]/database/database/`
- La documentación se encuentra en `RefactorX/Base/[nombre_modulo]/docs/`

### 2.4 Tecnologías Utilizadas

**Frontend:**
- Vue.js 3.5.22 (framework principal)
- Vue Router 4.6.3 (navegación)
- Axios 1.12.2 (comunicación HTTP)
- SweetAlert2 11.26.3 (alertas y confirmaciones)
- Vue Toastification 2.0.0-rc.5 (notificaciones)
- XLSX 0.18.5 (exportación a Excel)
- Font Awesome (iconografía)

**Backend:**
- Laravel 12 (framework PHP)
- Laravel Sanctum 4.0 (autenticación)
- L5-Swagger 9.0 (documentación de API)
- PHP 8.2

**Base de Datos:**
- PostgreSQL 16
- PL/pgSQL (lenguaje de stored procedures)

**Herramientas de desarrollo:**
- Vite 7.1.7 (build tool)
- Composer (gestión de dependencias PHP)
- NPM (gestión de dependencias JavaScript)

---

## 3. SISTEMA DE CONFIGURACIÓN GLOBAL

### 3.1 Configuración del Frontend

El frontend del sistema utiliza un archivo de configuración centralizado que define los parámetros fundamentales para el funcionamiento de la aplicación. Este archivo se encuentra en `src/config/app.config.js` y establece tres configuraciones críticas.

**Configuración de la API Base:**

El sistema necesita conocer la ubicación del backend para poder comunicarse con él. Esta URL se configura mediante la variable de entorno `VITE_API_BASE_URL`, que por defecto apunta a `http://127.0.0.1:8000` para desarrollo local. En producción, esta variable debe apuntar al servidor donde esté desplegado el backend Laravel.

```javascript
export const appConfig = {
  apiBaseUrl: import.meta.env.VITE_API_BASE_URL || 'http://127.0.0.1:8000',
  municipioId: parseInt(import.meta.env.VITE_MUNICIPIO_ID) || 39,
  tenant: 'guadalajara'
}
```

**Identificador del Municipio:**

Cada instancia del sistema está asociada a un municipio específico. Guadalajara tiene asignado el ID 39, que se utiliza en todas las consultas y operaciones para garantizar que los datos se filtren correctamente. Este identificador es fundamental para el funcionamiento multi-tenant del sistema.

**Tenant:**

El tenant identifica la instancia específica del sistema. Para Guadalajara, el valor es 'guadalajara', y este parámetro se incluye en todas las peticiones al backend para garantizar el aislamiento correcto de datos.

### 3.2 Sistema de API Genérico

El corazón de la comunicación entre el frontend y el backend es el servicio API genérico, implementado en `src/services/apiService.js`. Este servicio proporciona una interfaz unificada para ejecutar cualquier stored procedure del sistema.

El servicio expone principalmente dos métodos: `execute` y `executeStoredProcedure`. Ambos cumplen la misma función pero ofrecen diferentes niveles de flexibilidad en cuanto a los parámetros que aceptan.

**Método execute:**

Este es el método más utilizado en todo el sistema. Acepta seis parámetros que definen completamente la operación a realizar:

- `operacion`: El nombre del stored procedure a ejecutar
- `base`: El esquema de base de datos donde se encuentra el procedimiento
- `parametros`: Un objeto con los parámetros que requiere el stored procedure
- `tenant`: El identificador del tenant (por defecto 'guadalajara')
- `pagination`: Objeto con límite y offset para paginación
- `esquema`: Esquema de PostgreSQL (por defecto 'public')

El método construye una petición HTTP POST al endpoint `/api/generic` incluyendo todos estos parámetros en el cuerpo de la petición.

**Estructura de la petición:**

Cada petición enviada al backend sigue un formato estandarizado que incluye un objeto `eRequest` con toda la información necesaria:

```javascript
{
  eRequest: {
    Operacion: "sp_nombre_procedimiento",
    Base: "nombre_esquema",
    Parametros: [
      { value: "valor1", type: "string" },
      { value: 123, type: "integer" }
    ],
    Tenant: "guadalajara",
    Esquema: "public",
    Paginacion: {
      limit: 50,
      offset: 0
    }
  }
}
```

**Estructura de la respuesta:**

El backend siempre responde con una estructura consistente que facilita el manejo de errores y datos:

```javascript
{
  eResponse: {
    success: true,
    message: "Operación ejecutada correctamente",
    data: {
      result: [...],    // Array con los resultados
      count: 150,       // Total de registros
      debug: {          // Información de debugging
        connection: "nombre_base_datos",
        sp_name: "nombre_procedimiento",
        execution_time: "0.045s"
      }
    }
  }
}
```

### 3.3 Composable useApi

Para facilitar el uso del servicio API en los componentes Vue, el sistema proporciona un composable llamado `useApi` ubicado en `src/composables/useApi.js`. Este composable encapsula toda la lógica de comunicación con el backend y manejo de estados.

El composable gestiona tres estados reactivos fundamentales:

- `loading`: Indica si hay una petición en curso
- `error`: Almacena mensajes de error si la petición falla
- `data`: Contiene los datos devueltos por el backend

Cuando un componente necesita ejecutar un stored procedure, simplemente importa el composable y utiliza su método `execute`:

```javascript
import { useApi } from '@/composables/useApi'

const { loading, error, data, execute } = useApi()

const cargarDatos = async () => {
  await execute('sp_consulta', 'aseo_contratado', {
    parametro1: 'valor',
    parametro2: 123
  })
}
```

El composable automáticamente gestiona el estado de carga, captura errores y actualiza los datos de manera reactiva, lo que simplifica enormemente el código de los componentes.

### 3.4 Sistema de Rutas

El sistema de navegación está implementado con Vue Router y define más de 455 rutas que corresponden a todos los componentes de los ocho módulos. Las rutas siguen un patrón jerárquico que refleja la estructura modular del sistema.

Cada módulo tiene su propio grupo de rutas con un prefijo común. Por ejemplo, todas las rutas del módulo de Aseo Contratado comienzan con `/aseo-contratado/`, seguido del nombre específico de la funcionalidad.

Ejemplos de rutas:
- `/aseo-contratado/empresas` → ABC_Empresas.vue
- `/aseo-contratado/contratos` → Contratos.vue
- `/mercados/locales` → ABC_Locales.vue
- `/padron-licencias/consulta-licencia` → ConsultaLicenciafrm.vue

El router implementa lazy loading para todos los componentes, lo que significa que el código de cada vista se carga solo cuando el usuario navega a ella, mejorando significativamente el tiempo de carga inicial de la aplicación.

### 3.5 Componentes Compartidos

El sistema incluye un conjunto de componentes reutilizables que proporcionan funcionalidad común a todos los módulos. Estos componentes se encuentran en `src/components/common/` y son utilizados extensivamente en toda la aplicación.

**Modal:**

Componente para mostrar ventanas modales con contenido personalizado. Soporta diferentes tamaños, botones configurables y eventos de cierre y confirmación. Es utilizado para formularios de alta, edición y visualización de registros.

**DataTable:**

Tabla de datos con funcionalidades avanzadas como ordenamiento, paginación y acciones personalizables. Todos los módulos utilizan este componente para mostrar listados de información.

**GlobalLoading:**

Indicador de carga global que se muestra durante operaciones largas. Utiliza el composable `useGlobalLoading` para gestionar su estado de manera centralizada.

**LoadingOverlay:**

Overlay de carga que puede aplicarse sobre secciones específicas de la interfaz, útil para indicar que una parte de la página está procesando información.

**DocumentationModal:**

Modal especializado que muestra documentación contextual de ayuda para los usuarios, con pestañas para diferentes secciones de información.

Estos componentes garantizan una experiencia de usuario consistente en todos los módulos y reducen significativamente la duplicación de código.

---

## 4. MÓDULO: ASEO CONTRATADO

### 4.1 Descripción del Módulo

El módulo de Aseo Contratado gestiona todos los aspectos relacionados con los contratos de recolección de basura y servicios de aseo en el municipio. Administra las empresas recolectoras, los contratos vigentes, la generación de adeudos y el registro de pagos realizados.

Este módulo es fundamental para el control de ingresos municipales provenientes del servicio de recolección de basura, permitiendo un seguimiento detallado de cada contrato, desde su alta hasta su cancelación, incluyendo el control de pagos, adeudos y estados de cuenta.

### 4.2 Componentes Principales

El módulo está compuesto por 67 componentes Vue organizados en diferentes categorías funcionales:

**Administración de Catálogos (ABC):**

Los componentes ABC permiten la gestión completa de los catálogos maestros del módulo. Estos incluyen empresas recolectoras, tipos de aseo, zonas de servicio, unidades de recolección, tipos de empresa, recaudadoras, gastos operativos y recargos. Cada componente ABC implementa operaciones CRUD completas con validación de datos y confirmaciones de seguridad.

**Gestión de Contratos:**

El componente principal `Contratos.vue` permite el alta, consulta, modificación y cancelación de contratos de recolección. Incluye validación de datos, cálculo automático de montos y generación de períodos de obligación. El componente se integra con el catálogo de empresas y tipos de aseo para garantizar la consistencia de la información.

**Gestión de Adeudos:**

El sistema de adeudos es uno de los más complejos del módulo. Permite la inserción manual o masiva de adeudos, la aplicación de descuentos y condonaciones, el registro de pagos y la consulta de estados de cuenta. Los componentes de adeudos se comunican con múltiples stored procedures para calcular recargos, multas y actualizaciones de períodos vencidos.

**Reportes y Consultas:**

El módulo incluye múltiples componentes de reportes que permiten consultar contratos por diferentes criterios, estados de cuenta detallados, adeudos vencidos, estadísticas generales y conciliaciones de pagos. Todos los reportes incluyen funcionalidad de exportación a Excel.

### 4.3 Configuración del Módulo

**Base de datos:**

El módulo utiliza el esquema `aseo_contratado` en PostgreSQL. Las tablas principales están prefijadas con `ta_16_` siguiendo la convención del sistema legacy. Las tablas más importantes son:

- `ta_16_contratos`: Almacena los contratos de recolección
- `ta_16_empresas`: Catálogo de empresas recolectoras
- `ta_16_pagos`: Registro de pagos realizados
- `ta_16_adeudos`: Control de adeudos pendientes
- `ta_16_tipo_aseo`: Catálogo de tipos de servicio
- `ta_16_zonas`: Catálogo de zonas de servicio

**Stored Procedures:**

El módulo cuenta con 11 stored procedures principales que implementan la lógica de negocio:

- `sp16_contratos`: Gestión de contratos (listar, crear, actualizar, eliminar)
- `sp_empresas_list`: Listado de empresas recolectoras
- `sp_adeudos_insert`: Inserción de adeudos
- `sp_pagos_register`: Registro de pagos
- `sp_estado_cuenta`: Generación de estados de cuenta
- `sp_contratos_cancelar`: Cancelación de contratos
- `sp_adeudos_condonar`: Aplicación de condonaciones
- `sp_recargos_aplicar`: Cálculo y aplicación de recargos
- `sp_contratos_estadisticas`: Estadísticas generales
- `sp_pagos_conciliar`: Conciliación de pagos
- `sp_adeudos_vencidos`: Consulta de adeudos vencidos

**Parámetros del módulo:**

Cada llamada al módulo desde el frontend incluye los siguientes parámetros base:

```javascript
{
  operacion: "sp16_contratos",
  base: "aseo_contratado",
  tenant: "guadalajara",
  esquema: "public"
}
```

### 4.4 Flujos de Trabajo Principales

**Flujo de alta de contrato:**

1. El usuario accede al componente `Contratos.vue`
2. Completa el formulario seleccionando empresa, tipo de aseo, zona y unidades
3. El sistema valida la existencia de la empresa y la disponibilidad de la zona
4. Al guardar, se ejecuta el stored procedure `sp16_contratos` con operación INSERT
5. El sistema genera automáticamente los períodos de obligación según las fechas del contrato
6. Se crea el registro en `ta_16_contratos` con estado 'ACTIVO'
7. El sistema muestra confirmación y actualiza la lista de contratos

**Flujo de generación de adeudos:**

1. El usuario accede a `Adeudos_Carga.vue` o `Adeudos_Ins.vue`
2. Puede generar adeudos para un contrato específico o de manera masiva para todos los contratos vigentes
3. El sistema ejecuta `sp_adeudos_insert` que calcula el monto según el tipo de aseo y las unidades del contrato
4. Si existen adeudos anteriores vencidos, se aplican automáticamente los recargos configurados
5. Los adeudos se registran en `ta_16_adeudos` con el período correspondiente
6. El sistema actualiza el estado de cuenta del contrato

**Flujo de registro de pago:**

1. El usuario accede a `Adeudos_Pag.vue` o `Adeudos_PagMult.vue`
2. Consulta los adeudos pendientes de un contrato
3. Selecciona los adeudos a pagar (puede ser pago parcial o total)
4. Ingresa la información del pago (referencia, fecha, monto)
5. El sistema ejecuta `sp_pagos_register` que registra el pago y actualiza los adeudos
6. Si el pago cubre todo el adeudo, se marca como 'PAGADO'
7. Si es pago parcial, se actualiza el saldo pendiente
8. El sistema registra el movimiento en `ta_16_pagos` para auditoría

### 4.5 Integraciones

**Integración con tabla transversal de recaudadoras:**

El módulo se integra con la tabla `ta_12_recaudadoras` que es compartida por todos los módulos del sistema. Esta integración permite que los contratos y pagos se asocien correctamente a las oficinas recaudadoras del municipio.

**Integración con módulo de licencias:**

Existe una relación indirecta con el módulo de Padrón de Licencias a través del componente `Licencias_Relacionadas.vue`, que permite consultar si un contrato de aseo está asociado a una licencia comercial específica.

**Integración con convenios:**

El componente `DatosConvenio.vue` permite asociar contratos con convenios de pago especiales, lo que modifica las condiciones de facturación y los montos de los adeudos.

---

## 5. MÓDULO: CEMENTERIOS

### 5.1 Descripción del Módulo

El módulo de Cementerios administra todos los servicios relacionados con los cementerios municipales de Guadalajara. Gestiona la venta de espacios, los pagos de servicios, la generación de adeudos y la emisión de documentos relacionados con los diferentes cementerios del municipio.

El módulo maneja múltiples cementerios municipales, incluyendo el Cementerio de Guadalupe, Mezquitán, Jardines Guadalupanos y San Andrés Ixtlán. Cada cementerio tiene sus propias tarifas, secciones y tipos de espacios disponibles.

### 5.2 Componentes Principales

El módulo cuenta con 39 componentes Vue organizados en las siguientes categorías:

**Administración de Catálogos:**

Los componentes `ABCFolio.vue`, `ABCementer.vue` y `ABCRecargos.vue` permiten gestionar los catálogos maestros del módulo. Estos incluyen folios de servicios, información de cementerios y configuración de recargos por morosidad.

**Gestión de Pagos:**

Los componentes `ABCPagos.vue` y `ABCPagosxfol.vue` controlan el registro de pagos por servicios de cementerios. Permiten registrar pagos individuales o por folio, aplicar descuentos y generar recibos.

**Consultas por Cementerio:**

El módulo incluye componentes especializados para cada cementerio: `ConsultaGuada.vue` (Guadalupe), `ConsultaMez.vue` (Mezquitán), `ConsultaJardines.vue` (Jardines Guadalupanos), `ConsultaRCM.vue` (San Andrés Ixtlán). Cada componente permite consultar los espacios disponibles y los servicios específicos de cada cementerio.

**Gestión de Beneficios:**

Los componentes de bonificaciones (`Bonificacion.vue`), descuentos (`Descuento.vue`) y liquidaciones (`Liquidacion.vue`) permiten aplicar beneficios económicos a los usuarios según políticas municipales.

**Control de Accesos y Duplicados:**

El componente `Acceso.vue` controla el ingreso de vehículos y personas a los cementerios, mientras que `Duplicados.vue` gestiona la emisión de documentos duplicados.

### 5.3 Configuración del Módulo

**Base de datos:**

El módulo utiliza el esquema `cementerios` con tablas prefijadas con `ta_13_`:

- Tablas de espacios por cementerio
- Tablas de pagos y recibos
- Tablas de recargos y bonificaciones
- Catálogos de tipos de servicio

**Parámetros del módulo:**

```javascript
{
  operacion: "nombre_sp_cementerios",
  base: "cementerios",
  tenant: "guadalajara",
  esquema: "public"
}
```

### 5.4 Flujos de Trabajo Principales

**Flujo de venta de espacio:**

1. El usuario consulta los espacios disponibles en el cementerio específico
2. Selecciona el tipo de espacio (gaveta, fosa, cripta, etc.)
3. El sistema verifica la disponibilidad y calcula el costo
4. Se registra la venta con los datos del comprador
5. Se genera el folio de servicio
6. Se emite el recibo correspondiente

**Flujo de pago de servicios:**

1. El usuario consulta los adeudos pendientes por folio
2. Selecciona los servicios a pagar
3. El sistema calcula el monto total incluyendo recargos si aplican
4. Se registra el pago y se actualiza el estado del folio
5. Se emite el comprobante de pago

### 5.5 Integraciones

El módulo se integra con la tabla `ta_12_recaudadoras` para el control de oficinas y con el sistema de recibos general del municipio.

---

## 6. MÓDULO: ESTACIONAMIENTO EXCLUSIVO

### 6.1 Descripción del Módulo

El módulo de Estacionamiento Exclusivo gestiona los permisos de estacionamiento exclusivo en vías públicas del municipio. Administra las solicitudes, aprobaciones, renovaciones y cancelaciones de estos permisos especiales, así como el control de pagos y adeudos asociados.

Los permisos de estacionamiento exclusivo permiten a comercios y particulares reservar espacios de estacionamiento frente a sus establecimientos mediante el pago de una cuota anual o mensual establecida por el municipio.

### 6.2 Componentes Principales

El módulo cuenta con 69 componentes que cubren todo el ciclo de vida de los permisos:

**Administración de Catálogos:**

Componentes para gestionar zonas, tarifas, tipos de permiso y ejecutores de apremios. Incluyen validación de datos y control de vigencias.

**Gestión de Apremios:**

Los componentes de apremios (`ta_15_apremios`) controlan las solicitudes de permisos, sus renovaciones y cancelaciones. Incluyen validación de ubicación, verificación de disponibilidad de espacios y cálculo de montos.

**Control de Pagos:**

Componentes especializados para el registro de pagos, aplicación de descuentos y generación de estados de cuenta. Incluyen funcionalidad de conciliación con sistemas bancarios.

**Reportes Especializados:**

El módulo incluye reportes de permisos vigentes, vencidos, por zona, por tipo y estadísticas generales de ocupación.

### 6.3 Configuración del Módulo

**Base de datos:**

Utiliza el esquema `estacionamiento_exclusivo` con la tabla principal `ta_15_apremios` que almacena todos los permisos. Las tablas auxiliares incluyen catálogos de zonas, ejecutores y tarifas.

**Stored Procedures:**

El módulo implementa 13 stored procedures para las diferentes operaciones:

- Alta de permisos
- Renovación de permisos
- Cancelación de permisos
- Registro de pagos
- Generación de adeudos
- Consultas y reportes

**Parámetros del módulo:**

```javascript
{
  operacion: "sp15_apremios",
  base: "estacionamiento_exclusivo",
  tenant: "guadalajara",
  esquema: "public"
}
```

### 6.4 Flujos de Trabajo Principales

**Flujo de solicitud de permiso:**

1. El usuario ingresa la solicitud indicando ubicación y número de espacios
2. El sistema valida que la zona permita estacionamiento exclusivo
3. Se verifica la disponibilidad de espacios en la ubicación
4. Se calcula el monto a pagar según la tarifa vigente de la zona
5. Se genera la solicitud con estado 'PENDIENTE'
6. Una vez pagado, el permiso pasa a estado 'VIGENTE'
7. Se asigna un folio único al permiso

**Flujo de renovación:**

1. El sistema identifica permisos próximos a vencer
2. El usuario consulta el permiso por folio o ubicación
3. Se valida que el permiso esté vigente o recién vencido
4. Se calcula el monto de renovación según tarifa actual
5. Se registra el pago de renovación
6. Se extiende la vigencia del permiso
7. Se mantiene el mismo folio del permiso original

### 6.5 Integraciones

El módulo se integra con el sistema de zonas municipales y con las recaudadoras para el control de pagos. También tiene conexión con el módulo de Padrón de Licencias para verificar que los comercios solicitantes cuenten con licencia vigente.

---

## 7. MÓDULO: ESTACIONAMIENTO PÚBLICO

### 7.1 Descripción del Módulo

El módulo de Estacionamiento Público administra los estacionamientos públicos operados directamente por el municipio. Controla el acceso de vehículos, la generación de tickets, el cobro de tarifas, la conciliación de ingresos y la generación de reportes operativos y financieros.

Este módulo es crítico para el control de ingresos provenientes de los estacionamientos municipales, incluyendo el estacionamiento subterráneo de la plaza de armas y otros estacionamientos bajo administración municipal.

### 7.2 Componentes Principales

El módulo está compuesto por 47 componentes organizados funcionalmente:

**Control de Acceso:**

Componentes para registrar el ingreso y salida de vehículos, generación automática de tickets, cálculo de tarifas según tiempo de permanencia y registro de pagos en tiempo real.

**Administración:**

Los componentes administrativos permiten gestionar las tarifas, configurar los horarios especiales, administrar los usuarios operadores del sistema y controlar las unidades de estacionamiento.

**Conciliación Bancaria:**

El componente `ConciliacionBanorte.vue` implementa la conciliación automática con los pagos procesados a través de Banorte, permitiendo identificar diferencias y generar reportes de conciliación.

**Generación de Archivos:**

Componentes especializados para generar archivos de interfaz con sistemas externos, incluyendo archivos de movimientos diarios, cortes de caja y reportes para contabilidad.

**Reportes Operativos:**

El módulo incluye reportes de ocupación, estadísticas de uso, ingresos por período, tickets pendientes de pago y análisis de patrones de uso.

### 7.3 Configuración del Módulo

**Base de datos:**

El módulo utiliza esquemas específicos para diferentes estacionamientos, con tablas que registran cada transacción de entrada y salida de vehículos.

**Unidades procesadas:**

El módulo maneja 58 unidades de estacionamiento diferentes, cada una con su propia configuración de tarifas y capacidad.

**Stored Procedures:**

Cuenta con 5 stored procedures principales que gestionan:

- Registro de entrada/salida
- Cálculo de tarifas
- Generación de reportes
- Conciliación de pagos
- Estadísticas de ocupación

**Parámetros del módulo:**

```javascript
{
  operacion: "sp_estacionamiento_publico",
  base: "padron_licencias",  // Comparte base con licencias
  tenant: "guadalajara",
  esquema: "dbestacion"
}
```

### 7.4 Flujos de Trabajo Principales

**Flujo de ingreso de vehículo:**

1. El vehículo llega a la entrada del estacionamiento
2. El operador registra la entrada indicando placas y hora
3. El sistema genera un ticket único con código de barras
4. Se registra el espacio asignado si aplica
5. El ticket se entrega al conductor

**Flujo de salida y pago:**

1. El conductor presenta el ticket en la salida
2. El sistema calcula el tiempo de permanencia
3. Se calcula la tarifa según la tabla de precios vigente
4. El conductor realiza el pago (efectivo o tarjeta)
5. El sistema registra el pago y libera el ticket
6. Se autoriza la salida del vehículo
7. La transacción se registra para conciliación

**Flujo de conciliación:**

1. Al cierre del día, el sistema genera el reporte de transacciones
2. Se consultan los pagos procesados por Banorte
3. El componente de conciliación compara ambos registros
4. Se identifican diferencias y se marcan para revisión
5. Se genera el reporte de conciliación para contabilidad

### 7.5 Integraciones

El módulo se integra con Banorte para el procesamiento de pagos con tarjeta, con el sistema contable municipal para el registro de ingresos y con el módulo de Padrón de Licencias para validar pensiones de estacionamiento comercial.

---

## 8. MÓDULO: MERCADOS

### 8.1 Descripción del Módulo

El módulo de Mercados administra los locales comerciales dentro de los mercados municipales de Guadalajara. Gestiona la asignación de locales, el cobro de rentas, el control de adeudos, la aplicación de multas y la generación de reportes estadísticos sobre la ocupación y operación de los mercados.

El municipio de Guadalajara opera aproximadamente 30 mercados municipales distribuidos en diferentes zonas de la ciudad. Cada mercado tiene sus propias características, número de locales, categorías y tarifas específicas.

### 8.2 Componentes Principales

El módulo es el más grande del sistema con 108 componentes Vue:

**Administración de Mercados:**

Componentes para gestionar el catálogo de mercados, sus ubicaciones, características y administradores. Incluyen información detallada de cada mercado como capacidad, servicios disponibles y zonas.

**Gestión de Locales:**

Los componentes de locales (`ABC_Locales.vue`) permiten el alta, baja y modificación de locales dentro de cada mercado. Controlan la asignación de locatarios, las renovaciones de contratos y los cambios de giro comercial.

**Control de Rentas:**

Componentes especializados para la generación de rentas mensuales, el registro de pagos, la aplicación de descuentos y el control de adeudos. Incluyen cálculo automático de recargos por mora.

**Gestión de Cuotas:**

El módulo maneja diferentes tipos de cuotas además de la renta: cuotas de energía eléctrica, cuotas extraordinarias, cuotas de mantenimiento y cuotas especiales aprobadas por el ayuntamiento.

**Reportes Especializados:**

Amplia variedad de reportes incluyendo ocupación por mercado, adeudos totales, locales disponibles, estadísticas de pagos, análisis por categoría de local y reportes financieros consolidados.

### 8.3 Configuración del Módulo

**Base de datos:**

El módulo utiliza el esquema `mercados` con tablas prefijadas `ta_11_`:

- `ta_11_mercados`: Catálogo de mercados municipales
- `ta_11_locales`: Información de cada local comercial
- `ta_11_adeudo_local`: Control de adeudos de renta
- `ta_11_adeudo_energ`: Control de adeudos de energía
- `ta_11_cuo_locales`: Registro de cuotas aplicadas
- `ta_11_categoria`: Catálogo de categorías de locales
- `ta_11_secciones`: Secciones dentro de cada mercado
- `ta_11_cve_cuota`: Catálogo de tipos de cuota

**Stored Procedures:**

El módulo implementa 25 stored procedures que cubren:

- CRUD de mercados y locales
- Generación de adeudos mensuales
- Registro de pagos
- Aplicación de descuentos y condonaciones
- Cálculo de recargos
- Generación de reportes
- Consultas especializadas por mercado
- Estadísticas de ocupación

**Parámetros del módulo:**

```javascript
{
  operacion: "sp11_locales",
  base: "mercados",
  tenant: "guadalajara",
  esquema: "comun"
}
```

### 8.4 Flujos de Trabajo Principales

**Flujo de asignación de local:**

1. El usuario consulta los locales disponibles en un mercado específico
2. Selecciona el local a asignar verificando su estado
3. Captura los datos del locatario (nombre, RFC, contacto)
4. Define el giro comercial que operará en el local
5. Establece la categoría y la tarifa aplicable
6. El sistema registra la asignación con fecha de inicio
7. Se genera automáticamente el primer adeudo de renta

**Flujo de generación de adeudos:**

1. El sistema ejecuta un proceso mensual automático o manual
2. Consulta todos los locales ocupados activos
3. Para cada local genera un adeudo según su categoría y tarifa
4. Si existen adeudos vencidos, calcula y aplica recargos
5. Los adeudos se registran en `ta_11_adeudo_local`
6. Se genera un reporte de adeudos generados
7. El sistema notifica a los administradores de mercados

**Flujo de pago de renta:**

1. El locatario acude a pagar a la oficina recaudadora
2. El operador consulta los adeudos pendientes del local
3. El locatario puede pagar uno o varios períodos
4. El sistema registra el pago y actualiza los adeudos
5. Se emite el recibo oficial de pago
6. Los adeudos pagados cambian a estado 'PAGADO'
7. El movimiento se registra para conciliación contable

**Flujo de aplicación de cuota de energía:**

1. El administrador del mercado captura los consumos de energía
2. El sistema distribuye el costo total entre los locales activos
3. Se genera el adeudo de energía en `ta_11_adeudo_energ`
4. Los locatarios pueden pagar junto con la renta o por separado
5. Se registran los pagos y se actualizan los saldos

### 8.5 Integraciones

**Integración con tabla de recaudadoras:**

Los locales están asociados a oficinas recaudadoras específicas donde los locatarios deben realizar sus pagos.

**Integración con zonas:**

Los mercados están organizados por zonas geográficas (`ta_12_zonas`) que determina

n jurisdicciones administrativas y zonas de facturación.

**Integración con categorías:**

Cada local pertenece a una categoría (`ta_11_categoria`) que define la tarifa base aplicable, las obligaciones especiales y los servicios incluidos.

---

## 9. MÓDULO: MULTAS Y REGLAMENTOS

### 9.1 Descripción del Módulo

El módulo de Multas y Reglamentos administra las infracciones a los reglamentos municipales y las sanciones económicas asociadas. Gestiona el registro de actas, la notificación de multas, el control de pagos, los convenios de pago y los procesos de recurso o apelación.

El módulo cubre diferentes tipos de infracciones: sanitarias, comerciales, de construcción, ambientales, de imagen urbana y otras establecidas en los reglamentos municipales vigentes.

### 9.2 Componentes Principales

El módulo cuenta con 108 componentes organizados en varias categorías:

**Registro de Infracciones:**

Componentes para el levantamiento de actas de infracción, registro de visitas de inspección, notificación a infractores y seguimiento del proceso sancionador.

**Gestión de Multas:**

Control del catálogo de multas según el reglamento aplicable, cálculo de montos según la infracción, aplicación de agravantes o atenuantes y generación de resoluciones.

**Control de Pagos:**

Componentes para el registro de pagos de multas, aplicación de descuentos por pronto pago, planes de pago convenidos y control de saldos pendientes.

**Recursos y Apelaciones:**

Gestión de recursos de inconformidad, registro de alegatos, seguimiento de procesos de apelación y emisión de resoluciones definitivas.

**Reportes Especializados:**

Reportes de multas impuestas por período, tipo y monto, estadísticas de infracciones, análisis de recaudación, multas pagadas vs pendientes y efectividad de la fiscalización.

### 9.3 Configuración del Módulo

**Base de datos:**

Utiliza el esquema `multas_reglamentos` con tablas especializadas para cada tipo de infracción y proceso.

**Stored Procedures:**

El módulo implementa 22 stored procedures que cubren:

- Registro de actas de infracción
- Cálculo de multas
- Registro de pagos
- Gestión de recursos
- Consultas especializadas
- Generación de reportes
- Procesos de notificación
- Control de prescripciones

**Parámetros del módulo:**

```javascript
{
  operacion: "sp_multas",
  base: "multas_reglamentos",
  tenant: "guadalajara",
  esquema: "public"
}
```

### 9.4 Flujos de Trabajo Principales

**Flujo de imposición de multa:**

1. El inspector detecta una infracción al reglamento
2. Levanta un acta de infracción con los detalles
3. Notifica al infractor y le entrega copia del acta
4. El sistema calcula el monto de la multa según el tabulador
5. Se genera el folio de pago y se establece el plazo
6. El acta pasa a estado 'NOTIFICADA'
7. Se programa el seguimiento del pago

**Flujo de pago de multa:**

1. El infractor acude a pagar con el folio del acta
2. El sistema consulta el monto a pagar
3. Si paga dentro del plazo, puede aplicar descuento por pronto pago
4. Se registra el pago y se actualiza el estado del acta
5. El acta pasa a estado 'PAGADA'
6. Se emite el recibo y se archiva el expediente

**Flujo de recurso de inconformidad:**

1. El infractor presenta recurso de inconformidad
2. Se registra el recurso y se suspende el proceso de cobro
3. El área jurídica revisa el recurso
4. Se emite una resolución que puede confirmar, modificar o revocar la multa
5. Se notifica la resolución al recurrente
6. Si se confirma, se reactiva el proceso de pago
7. Si se revoca, el acta pasa a estado 'CANCELADA'

### 9.5 Integraciones

El módulo se integra con el Padrón de Licencias para verificar la situación de establecimientos comerciales que son objeto de multas. También se conecta con el módulo de Obras Públicas para multas relacionadas con construcciones irregulares.

---

## 10. MÓDULO: OTRAS OBLIGACIONES

### 10.1 Descripción del Módulo

El módulo de Otras Obligaciones agrupa diferentes conceptos de ingresos municipales que no están cubiertos por los módulos especializados. Incluye permisos especiales, concesiones diversas, aprovechamientos y otros conceptos de recaudación establecidos en la Ley de Ingresos del municipio.

Este módulo es altamente configurable, permitiendo la creación de nuevos conceptos de cobro sin necesidad de desarrollo adicional, mediante el uso de tablas genéricas de configuración.

### 10.2 Componentes Principales

El módulo cuenta con 27 componentes principalmente enfocados en:

**Administración de Tablas Configurables:**

Los componentes `t34_tablas` y `t34_etiq` permiten configurar nuevos tipos de obligaciones, definir sus campos, etiquetas y reglas de cálculo sin modificar código.

**Gestión de Adeudos Generales:**

Componentes para generar adeudos de conceptos diversos, registrar pagos, aplicar descuentos y consultar estados de cuenta.

**Reportes Configurables:**

Sistema de reportes flexible que se adapta a los diferentes tipos de obligaciones configuradas en el sistema.

### 10.3 Configuración del Módulo

**Base de datos:**

Utiliza el esquema `otrasoblig` con dos tablas principales de configuración:

- `t34_tablas`: Define los tipos de obligaciones configurables
- `t34_etiq`: Define las etiquetas y campos de cada tipo

Esta arquitectura permite crear nuevos conceptos de cobro mediante configuración, sin necesidad de crear nuevas tablas ni stored procedures.

**Stored Procedures:**

El módulo tiene 74 stored procedures, la mayoría configurables y parametrizables para adaptarse a diferentes tipos de obligaciones:

- Procedimientos de generación de adeudos genéricos
- Procedimientos de registro de pagos
- Procedimientos de consulta configurables
- Procedimientos de reportes dinámicos

**Parámetros del módulo:**

```javascript
{
  operacion: "sp_otras_obligaciones",
  base: "otras_obligaciones",
  tenant: "guadalajara",
  esquema: "otrasoblig",
  tabla: "34",  // Identificador de tabla configurable
  tipo_operacion: "adeudo"
}
```

### 10.4 Flujos de Trabajo Principales

**Flujo de configuración de nueva obligación:**

1. El administrador accede al catálogo de tablas (t34_tablas)
2. Define un nuevo tipo de obligación con su clave y descripción
3. Configura las etiquetas y campos necesarios en t34_etiq
4. Establece las reglas de cálculo y validación
5. La nueva obligación queda disponible para uso inmediato
6. No requiere despliegue ni modificación de código

**Flujo de generación de adeudos:**

1. Se identifica el concepto de obligación a aplicar
2. Se consulta la configuración de la tabla correspondiente
3. Se generan los adeudos según las reglas configuradas
4. Los adeudos se almacenan en la tabla dinámica
5. Se notifica a los obligados según corresponda

### 10.5 Integraciones

El módulo se integra con todos los demás módulos del sistema, ya que puede generar obligaciones complementarias a cualquier trámite o servicio municipal.

---

## 11. MÓDULO: PADRÓN DE LICENCIAS

### 11.1 Descripción del Módulo

El módulo de Padrón de Licencias es el sistema más complejo del proyecto recodeGDL. Administra todo el ciclo de vida de las licencias comerciales, industriales y de servicios del municipio, desde la solicitud inicial hasta la renovación, modificación o baja definitiva.

El módulo controla no solo las licencias sino también los anuncios publicitarios asociados, los trámites en proceso, las certificaciones, constancias y responsivas, además de implementar un sistema completo de bloqueos y validaciones que garantizan el cumplimiento de los requisitos legales.

### 11.2 Componentes Principales

El módulo cuenta con 141 componentes Vue, el conjunto más grande del sistema, organizados en múltiples categorías:

**Consultas:**

Los componentes de consulta permiten buscar información de usuarios, trámites, licencias y anuncios mediante diferentes criterios. Incluyen `ConsultaUsuariofrm.vue`, `ConsultaTramitefrm.vue`, `ConsultaLicenciafrm.vue` y `ConsultaAnunciofrm.vue`.

**Gestión de Trámites:**

Componentes para el alta de nuevos trámites, modificación, cancelación, reactivación y seguimiento. Incluyen control de documentos, validaciones de requisitos y generación de folios únicos. Componentes principales: `ModificarTramitefrm.vue`, `CancelarTramitefrm.vue`, `ReactivarTramitefrm.vue`, `BloquearTramitefrm.vue`.

**Gestión de Licencias:**

Control completo del ciclo de vida de licencias comerciales. Incluye alta, modificación, baja, bloqueo, consulta de licencias vigentes, licencias con adeudo y agrupación de licencias. Componentes: `ModificarLicenciafrm.vue`, `bajaLicenciafrm.vue`, `BloquearLicenciafrm.vue`, `LicenciasVigentesfrm.vue`, `LicenciasAdeudofrm.vue`, `GruposLicenciafrm.vue`.

**Gestión de Anuncios:**

Administración de anuncios publicitarios asociados a licencias. Permite alta, baja, bloqueo y vinculación de anuncios con licencias. Componentes: `bajaAnunciofrm.vue`, `BloquearAnunciofrm.vue`, `LigarAnunciofrm.vue`, `GruposAnunciofrm.vue`.

**Emisión de Documentos:**

Componentes para la generación de constancias, certificaciones y dictámenes. Cada tipo de documento tiene sus propias validaciones y formato. Componentes: `Constanciasfrm.vue`, `Certificacionesfrm.vue`, `Dictamenesfrm.vue`.

**Registro de Solicitudes:**

El componente `RegistroSolicitudfrm.vue` permite capturar nuevas solicitudes de licencia con toda la información requerida, validando requisitos y generando el expediente inicial.

**Catálogos Maestros:**

Gestión de los catálogos fundamentales del módulo: actividades comerciales, giros, requisitos por giro y códigos SCIAN. Componentes: `CatalogoActividadesFrm.vue`, `CatalogoGirosFrm.vue`, `CatalogoRequisitosFrm.vue`, `buscagirofrm.vue`.

### 11.3 Configuración del Módulo

**Base de datos:**

El módulo utiliza principalmente el esquema `comun` en la base de datos `padron_licencias`, compartiendo algunas tablas con otros módulos pero manteniendo sus tablas principales:

Tablas principales:
- `licencias`: Tabla maestra de licencias comerciales
- `anuncios`: Anuncios publicitarios
- `tramites`: Trámites en proceso
- `bloqueo`: Control de bloqueos de licencias, anuncios y trámites
- `constancias`: Constancias emitidas
- `certificaciones`: Certificaciones emitidas (19,301 registros históricos)
- `responsivas`: Responsivas emitidas

Catálogos:
- `c_giros`: Catálogo de giros comerciales (aprox. 800 giros)
- `c_actividades_lic`: Actividades económicas (aprox. 2,000 actividades)
- `c_scian`: Códigos del Sistema de Clasificación Industrial (1,000+ códigos)
- `c_girosreq`: Requisitos por giro
- `c_valoreslic`: Valores de licencias por año
- `giro_req`: Relación muchos a muchos entre giros y requisitos

**Stored Procedures:**

Aunque el módulo tiene solo 5 stored procedures principales generados en la refactorización actual, accede a cientos de procedimientos del sistema legacy para mantener compatibilidad:

- Procedimientos de consulta de licencias
- Procedimientos de gestión de trámites
- Procedimientos de emisión de documentos
- Procedimientos de validación de requisitos
- Procedimientos de cálculo de costos

**Parámetros del módulo:**

```javascript
{
  operacion: "sp_licencias",
  base: "padron_licencias",
  tenant: "guadalajara",
  esquema: "comun"
}
```

### 11.4 Flujos de Trabajo Principales

**Flujo completo de obtención de licencia:**

1. **Fase de Solicitud:**
   - El ciudadano presenta solicitud en ventanilla
   - El operador captura los datos en `RegistroSolicitudfrm.vue`
   - Se selecciona el giro comercial solicitado
   - El sistema consulta los requisitos aplicables al giro
   - Se genera un número de trámite único
   - El trámite se registra con estado 'EN_PROCESO'

2. **Fase de Validación:**
   - El área técnica revisa los documentos presentados
   - Se verifica que se cumplan todos los requisitos
   - Se valida que la ubicación permita el giro solicitado
   - Se consulta el predio catastral para validar la propiedad
   - Se verifica que no existan adeudos de predial

3. **Fase de Dictamen:**
   - El área jurídica emite dictamen favorable o no favorable
   - Si es favorable, se calcula el costo de la licencia
   - Se genera la línea de captura para pago
   - El trámite pasa a estado 'AUTORIZADO_PENDIENTE_PAGO'

4. **Fase de Pago y Expedición:**
   - El ciudadano realiza el pago en recaudadora
   - El sistema registra el pago y lo asocia al trámite
   - Se genera el número de licencia definitivo
   - Se crea el registro en la tabla `licencias` con estado 'VIGENTE'
   - El trámite original pasa a estado 'FINALIZADO'
   - Se emite la constancia de licencia

5. **Fase de Seguimiento:**
   - La licencia queda activa en el padrón
   - Se programa la fecha de renovación anual
   - El sistema genera los adeudos de refrendo automáticamente

**Flujo de modificación de licencia:**

1. El propietario solicita cambio (domicilio, giro, propietario, etc.)
2. Se abre un trámite de modificación vinculado a la licencia
3. Se validan los nuevos datos y requisitos si aplican
4. Se genera el pago por concepto de modificación si corresponde
5. Una vez pagado, se actualizan los datos de la licencia
6. Se registra el historial de modificaciones
7. El número de licencia se mantiene

**Flujo de baja de licencia:**

1. El propietario solicita la baja de la licencia
2. El sistema verifica que no existan adeudos pendientes
3. Si hay adeudos, debe liquidarlos antes de la baja
4. Se genera un trámite de baja
5. Se verifica que no haya anuncios activos asociados
6. Se procesa la baja y la licencia pasa a estado 'BAJA'
7. Se emite el documento de liberación

**Flujo de bloqueo de licencia:**

1. Se detecta una irregularidad (falta de pago, cambio de giro no autorizado, etc.)
2. El inspector o el sistema automático genera un bloqueo
3. Se registra en la tabla `bloqueo` con el motivo
4. La licencia pasa a estado `bloqueado = 1`
5. La licencia no puede realizar trámites hasta desbloquearse
6. Se notifica al propietario el motivo y los pasos para desbloquear
7. Una vez subsanada la irregularidad, se levanta el bloqueo

**Flujo de emisión de certificación:**

1. El interesado solicita una certificación
2. Se valida que la licencia esté vigente y sin bloqueos
3. Se genera el folio de certificación (formato: año/folio)
4. Se cobra el derecho por emisión de certificación
5. Se registra en la tabla `certificaciones`
6. Se emite el documento oficial con firmas y sellos digitales

### 11.5 Integraciones

**Integración con Catastro:**

El módulo se integra estrechamente con la información catastral a través de la tabla `convcta`, que vincula las cuentas catastrales con las licencias. Esta integración permite:

- Validar que el solicitante sea propietario del predio
- Verificar la situación de pago del predial
- Obtener la ubicación exacta del establecimiento
- Validar que el uso de suelo permita el giro solicitado

**Integración con Recaudadoras:**

Todas las licencias están asociadas a una recaudadora específica (tabla `ta_12_recaudadoras`) donde se realizan los pagos y trámites. Esta integración permite:

- Distribuir la carga de trabajo entre oficinas
- Controlar los ingresos por oficina
- Facilitar el acceso de los ciudadanos a la oficina más cercana

**Integración con Aseo Contratado:**

Existe un vínculo entre licencias comerciales y contratos de aseo a través del componente `Licencias_Relacionadas.vue`, que permite:

- Verificar que el establecimiento tenga contrato de recolección
- Asociar el pago de aseo con la licencia comercial
- Validar cumplimiento de obligaciones sanitarias

**Integración con Sistema de Ingresos:**

El módulo se integra con el sistema general de ingresos para:

- Generar líneas de captura para pagos
- Registrar los ingresos por concepto de licencias
- Aplicar las tarifas vigentes según la Ley de Ingresos
- Generar reportes financieros consolidados

### 11.6 Reglas de Negocio Principales

**Cálculo de costos:**

El costo de una licencia se determina por múltiples factores:

- Giro comercial (tabla `c_giros`)
- Superficie del establecimiento
- Ubicación (zona de la ciudad)
- Año fiscal (tabla `c_valoreslic`)
- Tipo de trámite (nueva, renovación, modificación)

**Requisitos por giro:**

Cada giro comercial tiene requisitos específicos definidos en la tabla relacional `giro_req`. Los requisitos más comunes incluyen:

- Uso de suelo compatible
- Certificado de protección civil
- Permiso de salubridad
- Estudio de impacto ambiental (para giros especiales)
- Anuencia de vecinos (para giros con impacto en zona)
- Dictamen estructural (para modificaciones mayores)

**Vigencia y renovación:**

Las licencias tienen vigencia anual. El sistema:

- Genera automáticamente adeudos de refrendo cada año
- Permite renovación anticipada con descuento
- Marca como vencidas las licencias no renovadas después de 90 días
- Mantiene el número de licencia a través de las renovaciones

**Sistema de bloqueos:**

Los bloqueos pueden ser:

- **Administrativos**: Por falta de pago o documentación faltante
- **Técnicos**: Por cambios no autorizados en el establecimiento
- **Legales**: Por resoluciones judiciales o administrativas
- **Sanitarios**: Por clausuras de salubridad

Un elemento bloqueado no puede:
- Realizar modificaciones
- Obtener certificaciones
- Tramitar anuncios
- Renovarse

Debe primero subsanarse la causa del bloqueo.

---

## 12. INTEGRACIÓN ENTRE MÓDULOS

### 12.1 Tabla Hub: ta_12_recaudadoras

La tabla `ta_12_recaudadoras` es la pieza fundamental de integración entre todos los módulos del sistema. Esta tabla del esquema `comun` contiene el catálogo de todas las oficinas recaudadoras del municipio, y prácticamente todas las transacciones del sistema están asociadas a una recaudadora específica.

**Campos principales:**
- `id_rec`: Identificador único de la recaudadora
- `recaudadora`: Nombre de la oficina
- `domicilio`: Ubicación física
- `telefono`: Teléfono de contacto
- `mpio`: Municipio (siempre 39 para Guadalajara)
- `recaudador`: Nombre del recaudador responsable

**Uso en cada módulo:**

- **Aseo Contratado**: Campo `recaud` en `ta_16_contratos`
- **Padrón de Licencias**: Campo `recaud` en `licencias`
- **Mercados**: Campo `oficina` en `ta_11_locales`
- **Estacionamiento Exclusivo**: Campo `zona` en `ta_15_apremios`
- **Multas**: Campo `recaudadora` en tablas de infracciones
- **Cementerios**: Campo `oficina` en tablas de servicios

Esta integración permite:
- Distribuir la carga de trabajo entre oficinas
- Generar reportes consolidados por recaudadora
- Controlar ingresos por oficina
- Facilitar la conciliación contable
- Asignar responsabilidades por zona geográfica

### 12.2 Integración con Catastro

Varios módulos requieren validar información catastral, principalmente Padrón de Licencias. La integración se realiza a través de:

**Tabla convcta:**

Esta tabla vincula las cuentas catastrales con los registros del sistema:

- `cvecuenta`: Clave única de la cuenta catastral
- `cuenta_catastral`: Número de cuenta visible al usuario
- `propietario`: Nombre del propietario según catastro

**Validaciones que permite:**

- Verificar propiedad del predio al solicitar licencia
- Consultar adeudos de predial antes de autorizar trámites
- Validar que el uso de suelo permita el giro comercial
- Obtener la superficie del predio para cálculos

### 12.3 Flujos Multi-Módulo

Algunos procesos requieren la intervención de múltiples módulos:

**Ejemplo 1: Establecimiento Comercial Completo**

1. **Padrón de Licencias**: Se tramita la licencia comercial
2. **Aseo Contratado**: Se contrata el servicio de recolección
3. **Estacionamiento Exclusivo**: Se solicita permiso de estacionamiento
4. **Multas**: Se registran inspecciones periódicas

Todos estos registros comparten:
- La misma cuenta catastral
- El mismo propietario
- La misma recaudadora

**Ejemplo 2: Local en Mercado con Licencia**

1. **Mercados**: Se asigna el local comercial
2. **Padrón de Licencias**: Se tramita la licencia para operar
3. **Multas**: Se inspeccionan las condiciones sanitarias
4. **Aseo**: El mercado tiene un contrato general

La integración permite validar que el locatario:
- Tenga su local al corriente
- Cuente con licencia vigente
- No tenga multas pendientes

### 12.4 Tablas Transversales Adicionales

**ta_12_operaciones:**

Catálogo de operaciones del sistema utilizado para auditoría y control de accesos:

- Define qué operaciones puede realizar cada usuario
- Registra en bitácora cada operación ejecutada
- Permite generar reportes de actividad por usuario

**ta_12_passwords:**

Tabla de usuarios del sistema:

- Almacena credenciales de acceso
- Define permisos por módulo
- Controla la vigencia de las cuentas
- Registra actividad de login

Todos los módulos validan contra esta tabla al iniciar sesión.

**ta_12_cuentas:**

Catálogo de cuentas contables:

- Define las cuentas contables donde se registran los ingresos
- Utilizada por Aseo Contratado y Mercados principalmente
- Facilita la integración con el sistema contable municipal

### 12.5 Reportes Consolidados

El sistema permite generar reportes que consolidan información de múltiples módulos:

- **Reporte de Ingresos Totales**: Suma ingresos de todos los módulos por período
- **Reporte por Recaudadora**: Consolida los ingresos de todos los conceptos por oficina
- **Reporte por Contribuyente**: Muestra todas las obligaciones de un contribuyente específico en todos los módulos
- **Reporte de Adeudos Totales**: Consolida todos los adeudos pendientes del municipio

---

## 13. GUÍA DE PARAMETRIZACIÓN

### 13.1 Parametrización del Frontend

Para configurar correctamente el frontend del sistema, es necesario establecer las siguientes variables:

**Variables de Entorno:**

Crear un archivo `.env` en la raíz de `RefactorX/FrontEnd/` con el siguiente contenido:

```bash
# URL del backend Laravel
VITE_API_BASE_URL=http://192.168.6.146:8000

# ID del municipio (Guadalajara = 39)
VITE_MUNICIPIO_ID=39

# Entorno de ejecución
VITE_APP_ENV=production
```

Para desarrollo local:

```bash
VITE_API_BASE_URL=http://127.0.0.1:8000
VITE_MUNICIPIO_ID=39
VITE_APP_ENV=development
```

**Configuración del Proxy (vite.config.js):**

El archivo `vite.config.js` ya está configurado para proxear las peticiones API durante el desarrollo. Si se requiere modificar, se debe ajustar la sección `server.proxy`:

```javascript
server: {
  port: 3000,
  proxy: {
    '/api': {
      target: 'http://127.0.0.1:8000',
      changeOrigin: true
    }
  }
}
```

**Instalación de Dependencias:**

```bash
cd RefactorX/FrontEnd
npm install
```

**Ejecución en Desarrollo:**

```bash
npm run dev
```

La aplicación estará disponible en `http://localhost:3000`

**Construcción para Producción:**

```bash
npm run build
```

Los archivos de producción se generarán en `RefactorX/FrontEnd/dist/`

### 13.2 Parametrización del Backend

**Variables de Entorno:**

Crear un archivo `.env` en la raíz de `RefactorX/BackEnd/` basándose en `.env.example`:

```bash
APP_NAME=recodeGDL
APP_ENV=production
APP_KEY=base64:generada_por_laravel
APP_DEBUG=false
APP_URL=http://192.168.6.146:8000

# Configuración de Base de Datos Principal
DB_CONNECTION=pgsql
DB_HOST=192.168.6.146
DB_PORT=5432
DB_DATABASE=padron_licencias
DB_USERNAME=refact
DB_PASSWORD=FF)-BQk2

# Configuración adicional PostgreSQL
DB_SCHEMA=public
DB_SSLMODE=prefer

# Configuración de sesiones
SESSION_DRIVER=file
SESSION_LIFETIME=120

# Configuración de logs
LOG_CHANNEL=stack
LOG_LEVEL=debug
```

**Generación de la App Key:**

```bash
cd RefactorX/BackEnd
php artisan key:generate
```

**Instalación de Dependencias:**

```bash
composer install --optimize-autoloader --no-dev
```

Para desarrollo:

```bash
composer install
```

**Optimización para Producción:**

```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

**Ejecución en Desarrollo:**

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

**Configuración del Servidor Web:**

Para producción con Nginx, configurar un server block:

```nginx
server {
    listen 80;
    server_name 192.168.6.146;
    root /ruta/a/RefactorX/BackEnd/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

### 13.3 Parametrización de Base de Datos

**Conexión a PostgreSQL:**

El sistema utiliza PostgreSQL 16. Verificar la conexión:

```bash
psql "postgresql://refact:FF)-BQk2@192.168.6.146:5432/padron_licencias"
```

**Esquemas Requeridos:**

El sistema utiliza los siguientes esquemas en PostgreSQL:

- `public`: Esquema principal con stored procedures
- `comun`: Tablas compartidas entre módulos
- `db_ingresos`: Tablas de ingresos
- `catastro_gdl`: Información catastral
- `informix`: Tablas legacy
- `otrasoblig`: Otras obligaciones

**Verificación de Stored Procedures:**

Consultar la cantidad de stored procedures disponibles:

```sql
SELECT schemaname, count(*)
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
GROUP BY schemaname;
```

**Permisos Requeridos:**

El usuario `refact` debe tener permisos de ejecución en todos los stored procedures:

```sql
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO refact;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA comun TO refact;
```

### 13.4 Parametrización por Módulo

Cada módulo requiere los siguientes parámetros básicos:

**Aseo Contratado:**
- Base: `aseo_contratado`
- Esquema: `public`
- Prefijo de tablas: `ta_16_`
- Prefijo de SPs: `sp16_`, `sp_aseo_`

**Cementerios:**
- Base: `cementerios`
- Esquema: `public`
- Prefijo de tablas: `ta_13_`
- Prefijo de SPs: `sp_cementerio_`

**Estacionamiento Exclusivo:**
- Base: `estacionamiento_exclusivo`
- Esquema: `public`
- Prefijo de tablas: `ta_15_`
- Prefijo de SPs: `sp15_`, `sp_apremio_`

**Estacionamiento Público:**
- Base: `padron_licencias`
- Esquema: `dbestacion`
- Prefijo de SPs: `sp_estacionamiento_`

**Mercados:**
- Base: `mercados`
- Esquema: `comun`
- Prefijo de tablas: `ta_11_`
- Prefijo de SPs: `sp11_`, `sp_mercado_`

**Multas y Reglamentos:**
- Base: `multas_reglamentos`
- Esquema: `public`
- Prefijo de SPs: `sp_multa_`, `sp_infraccion_`

**Otras Obligaciones:**
- Base: `otras_obligaciones`
- Esquema: `otrasoblig`
- Prefijo de tablas: `t34_`
- Prefijo de SPs: `sp_otras_`, `sp34_`

**Padrón de Licencias:**
- Base: `padron_licencias`
- Esquema: `comun`
- Tablas principales: `licencias`, `anuncios`, `tramites`
- Prefijo de SPs: `sp_licencia_`, `sp_tramite_`, `sp_anuncio_`

### 13.5 Configuración de Seguridad

**Autenticación Laravel Sanctum:**

El sistema utiliza Laravel Sanctum para la autenticación de API. Configurar en `.env`:

```bash
SANCTUM_STATEFUL_DOMAINS=192.168.6.146:3000,localhost:3000
SESSION_DOMAIN=.192.168.6.146
```

**CORS (Cross-Origin Resource Sharing):**

Configurar en `config/cors.php` o mediante `.env`:

```bash
CORS_ALLOWED_ORIGINS=http://192.168.6.146:3000,http://localhost:3000
```

**Configuración de JWT (opcional):**

Si se implementa JWT, configurar en `.env.jwt.example`:

```bash
JWT_SECRET=clave_secreta_generada
JWT_TTL=1440
JWT_REFRESH_TTL=20160
JWT_ALGO=HS256
```

---

## 14. ANEXOS

### 14.1 Glosario de Términos

**ABC**: Nomenclatura utilizada para componentes de Alta, Baja y Cambio (CRUD) de catálogos.

**Apremio**: Permiso de estacionamiento exclusivo en vía pública.

**Base**: Parámetro que identifica el esquema de base de datos en las llamadas al API.

**Composable**: Función reutilizable de Vue 3 que encapsula lógica reactiva.

**CTE (Common Table Expression)**: Expresión de tabla común en SQL utilizada para optimizar consultas.

**Folio**: Número único que identifica un trámite, documento o transacción.

**Giro**: Clasificación de actividad comercial o industrial.

**SP (Stored Procedure)**: Procedimiento almacenado en la base de datos que implementa lógica de negocio.

**Tenant**: Identificador de la instancia del sistema, permite multi-tenancy.

**Trámite**: Solicitud o proceso administrativo en curso.

### 14.2 Referencias

**Documentación del Proyecto:**
- DIAGRAMAS_CLASES_SUBSISTEMAS.md: Diagramas de clases detallados del sistema
- DIAGRAMAS_ER_DICCIONARIO_DATOS_VERIFICADO.md: Estructura de base de datos completa
- REPORTE_VERIFICACION_COMPLETA_BD.md: Verificación de stored procedures
- CONTEXT_SESION_DESPLIEGUE_SPS.md: Contexto del despliegue de procedimientos

**Documentación Técnica por Módulo:**
- RefactorX/Base/[modulo]/docs/README.md: Documentación específica de cada módulo
- RefactorX/Base/[modulo]/docs/admin/: Documentación de componentes administrativos

**Repositorios de Código:**
- RefactorX/FrontEnd/: Aplicación Vue.js
- RefactorX/BackEnd/: API Laravel
- RefactorX/Base/: Recursos y documentación

**Tecnologías:**
- Vue.js: https://vuejs.org/
- Laravel: https://laravel.com/
- PostgreSQL: https://www.postgresql.org/

### 14.3 Información de Contacto y Soporte

**Servidor de Base de Datos:**
- Host: 192.168.6.146
- Puerto: 5432
- Base de Datos Principal: padron_licencias
- Usuario: refact
- Password: FF)-BQk2

**Conexión psql:**
```bash
psql "postgresql://refact:FF)-BQk2@192.168.6.146:5432/padron_licencias"
```

**Municipio:**
- Nombre: Guadalajara
- ID: 39
- Tenant: guadalajara

### 14.4 Estadísticas del Sistema

**Componentes Vue por Módulo:**
1. Padrón de Licencias: 141 componentes (23%)
2. Mercados: 108 componentes (18%)
3. Multas y Reglamentos: 108 componentes (18%)
4. Estacionamiento Exclusivo: 69 componentes (11%)
5. Aseo Contratado: 67 componentes (11%)
6. Estacionamiento Público: 47 componentes (8%)
7. Cementerios: 39 componentes (6%)
8. Otras Obligaciones: 27 componentes (4%)

**Total: 606 componentes Vue**

**Stored Procedures por Módulo:**
1. Otras Obligaciones: 74 SPs
2. Mercados: 25 SPs
3. Multas y Reglamentos: 22 SPs
4. Estacionamiento Exclusivo: 13 SPs
5. Aseo Contratado: 11 SPs
6. Estacionamiento Público: 5 SPs
7. Padrón de Licencias: 5 SPs
8. Cementerios: 0 SPs (en desarrollo)

**Total: 155 SPs generados en la refactorización**

**Base de Datos:**
- Total de schemas: 10
- Total de tablas: 6,558
- Total de stored procedures legacy: 1,520
- Total de bases de datos: 13

**Líneas de Código:**
- Frontend Vue.js: ~54,000 líneas
- Backend Laravel: ~2,000 líneas
- Scripts SQL: ~500,000 líneas

### 14.5 Historial de Versiones

**Versión 1.0 - 13 de noviembre de 2025**
- Documentación inicial completa del sistema
- Descripción de los 8 módulos principales
- Configuración y parametrización detallada
- Guías de integración entre módulos
- Anexos con información técnica completa

---

**FIN DEL DOCUMENTO**

Este documento describe el estado completo del sistema recodeGDL al 13 de noviembre de 2025. Para actualizaciones o consultas adicionales, favor de consultar la documentación técnica de cada módulo o contactar al equipo de desarrollo.

**Generado por:** Análisis exhaustivo del código fuente y documentación existente
**Revisado por:** Equipo técnico del Municipio de Guadalajara
**Próxima revisión:** Según se implementen cambios significativos en la arquitectura
