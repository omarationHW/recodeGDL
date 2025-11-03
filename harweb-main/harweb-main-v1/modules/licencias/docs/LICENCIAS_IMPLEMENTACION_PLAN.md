# Plan de Implementación - Módulos de Licencias

## Descripción General
Este documento contiene el plan de implementación ordenado para todos los módulos del sistema de licencias. El proceso se divide en dos fases principales: Base de Datos (Stored Procedures) y Frontend (Componentes Vue).

---

## FASE 1: BASE DE DATOS - STORED PROCEDURES

### Prioridad Alta - Módulos Críticos (Implementar Primero)
1. **consultapredial** - Consulta de información predial
2. **busque** - Sistema de búsqueda general de licencias
3. **consultalicenciafrm** - Consulta de licencias comerciales
4. **consultaanunciofrm** - Consulta de anuncios publicitarios
5. **regsolicfrm** - Registro de solicitudes
6. **registrosolicitudform** - Formulario de registro de solicitudes

### Prioridad Media - Gestión de Licencias
7. **bajalicenciafrm** - Gestión de baja de licencias
8. **modlicfrm** - Modificación de licencias
9. **bloquearlicenciafrm** - Bloqueo temporal de licencias
10. **licenciasvigentesfrm** - Consulta de licencias vigentes
11. **modlicadeudofrm** - Modificación de licencias con adeudo
12. **constanciafrm** - Emisión de constancias
13. **constancianooficialfrm** - Constancias no oficiales

### Prioridad Media - Gestión de Anuncios
14. **bajaanunciofrm** - Administración de baja de anuncios
15. **bloquearanunciorm** - Bloqueo de anuncios
16. **consultaanunciofrm** - Consulta de anuncios
17. **ligaanunciofrm** - Vinculación de anuncios
18. **gruposanunciosfrm** - Gestión de grupos de anuncios

### Catálogos y Configuración
19. **catalogogirosfrm** - Catálogo de giros comerciales
20. **catalogoactividadesfrm** - Catálogo de actividades
21. **catrequisitos** - Catálogo de requisitos
22. **ligarequisitos** - Vinculación de requisitos
23. **tipobloqueofrm** - Tipos de bloqueo
24. **estatusfrm** - Estados del sistema

### Búsquedas y Consultas Avanzadas
25. **busquedaactividadfrm** - Búsqueda de actividades
26. **busquedascianfrm** - Búsqueda SCIAN
27. **buscagirofrm** - Búsqueda de giros
28. **empleadoslistado** - Listado de empleados
29. **consultausuariosfrm** - Consulta de usuarios
30. **consultatramitefrm** - Consulta de trámites

### Trámites y Procesos
31. **modtramitefrm** - Modificación de trámites
32. **cancelatramitefrm** - Cancelación de trámites
33. **bloqueartramitefrm** - Bloqueo de trámites
34. **reactivatramite** - Reactivación de trámites
35. **tramitebajalic** - Trámite de baja de licencias
36. **tramitebajaanun** - Trámite de baja de anuncios

### Reportes y Estadísticas
37. **repestadisticoslicfrm** - Reportes estadísticos
38. **reporteanunexcelfrm** - Reportes de anuncios en Excel
39. **repsuspendidasfrm** - Reporte de suspendidas
40. **repestado** - Reportes de estado
41. **repdoc** - Reportes de documentos

### Gestión de Documentos
42. **doctosfrm** - Gestión de documentos
43. **certificacionesfrm** - Certificaciones
44. **dictamenfrm** - Dictámenes
45. **dictamenusodesuelo** - Dictamen uso de suelo
46. **responsivafrm** - Responsivas
47. **formatosecologiafrm** - Formatos de ecología

### Gestión de Hologramas
48. **gestionhologramasfrm** - Gestión de hologramas
49. **prophologramasfrm** - Propuesta de hologramas

### Impresiones y Documentos Oficiales
50. **imprecibofrm** - Impresión de recibos
51. **impoficiofrm** - Impresión de oficios
52. **implicenciareglamentadafrm** - Impresión licencia reglamentada
53. **frmimplicenciareglamentada** - Formulario impresión licencia
54. **impsolinspeccionfrm** - Impresión solicitud inspección

### Consultas Especializadas
55. **conslic400frm** - Consulta licencias 400
56. **consanun400frm** - Consulta anuncios 400
57. **girosdconadeudofrm** - Giros con adeudo
58. **girosvigentesctexgirofrm** - Giros vigentes por cliente

### Gestión de Ubicaciones
59. **formabuscalle** - Formulario buscar calle
60. **formabuscolonia** - Formulario buscar colonia
61. **frmselcalle** - Selección de calles
62. **zonaanuncio** - Zona de anuncios
63. **zonalicencia** - Zona de licencias
64. **cruces** - Gestión de cruces

### Bloqueos Especializados
65. **bloqueodomiciliosfrm** - Bloqueo de domicilios
66. **h_bloqueodomiciliosfrm** - Historial bloqueo domicilios
67. **bloqueorfcfrm** - Bloqueo RFC

### Revisiones y Seguimiento
68. **revisionesfrm** - Revisiones
69. **observacionfrm** - Observaciones
70. **fechasegfrm** - Fechas de seguimiento
71. **agendavisitasfrm** - Agenda de visitas

### Gestión de Empresas y Dependencias
72. **empresasfrm** - Gestión de empresas
73. **dependenciasfrm** - Gestión de dependencias

### Utilidades del Sistema
74. **privilegios** - Gestión de privilegios
75. **sfrm_chgpass** - Cambio de contraseña
76. **sfrm_chgfirma** - Cambio de firma
77. **firmausuario** - Firma de usuario
78. **firma** - Gestión de firmas

### Pantallas de Sistema
79. **splash** - Pantalla de inicio
80. **psplash** - Pantalla splash
81. **semaforo** - Indicador de estado
82. **webbrowser** - Navegador web integrado
83. **sgcv2** - Sistema de gestión v2
84. **tdmconection** - Conexión TDM

### Carga de Datos
85. **carga** - Carga de datos
86. **cargadatosfrm** - Formulario carga de datos
87. **carga_imagen** - Carga de imágenes
88. **unidadimg** - Unidad de imágenes

### Gestión de Grupos
89. **gruposlicenciasfrm** - Grupos de licencias
90. **gruposlicenciasabcfrm** - ABC grupos licencias
91. **gruposanunciosabcfrm** - ABC grupos anuncios

### Utilidades Especiales
92. **catastrodm** - Catastro DM
93. **cartonva** - Cartón VA
94. **grs_dlg** - Diálogo GRS
95. **hastafrm** - Formulario hasta
96. **prepagofrm** - Prepago
97. **propuestatab** - Propuesta tabular
98. **reghfrm** - Registro H
99. **regsolicfrm_manual** - Registro solicitud manual

---

## FASE 2: FRONTEND - COMPONENTES VUE

### Prioridad de Implementación Frontend (Mismo Orden que BD)

Los componentes Vue deben implementarse en el mismo orden que los stored procedures, pero únicamente después de que cada stored procedure esté completamente funcional y probado.

### Estructura de Archivos Vue
Cada componente debe crearse en: `frontend-vue/src/components/modules/licencias/`

### Componentes por Implementar (97 total):

1. **consultapredial.vue**
2. **busque.vue** 
3. **consultaLicenciafrm.vue**
4. **consultaAnunciofrm.vue**
5. **regsolicfrm.vue**
6. **RegistroSolicitudForm.vue**
7. **bajaLicenciafrm.vue**
8. **modlicfrm.vue**
9. **BloquearLicenciafrm.vue**
10. **LicenciasVigentesfrm.vue**
11. **modlicAdeudofrm.vue**
12. **constanciafrm.vue**
13. **constanciaNoOficialfrm.vue**
14. **bajaAnunciofrm.vue**
15. **BloquearAnunciorm.vue**
16. **consultaAnunciofrm.vue**
17. **ligaAnunciofrm.vue**
18. **gruposAnunciosfrm.vue**
19. **catalogogirosfrm.vue**
20. **CatalogoActividadesFrm.vue**
21. **CatRequisitos.vue**
22. **LigaRequisitos.vue**
23. **tipobloqueofrm.vue**
24. **estatusfrm.vue**
25. **BusquedaActividadFrm.vue**
26. **BusquedaScianFrm.vue**
27. **buscagirofrm.vue**
28. **EmpleadosListado.vue**
29. **consultausuariosfrm.vue**
30. **ConsultaTramitefrm.vue**
31. **modtramitefrm.vue**
32. **cancelaTramitefrm.vue**
33. **BloquearTramitefrm.vue**
34. **ReactivaTramite.vue**
35. **TramiteBajaLic.vue**
36. **TramiteBajaAnun.vue**
37. **repEstadisticosLicfrm.vue**
38. **ReporteAnunExcelfrm.vue**
39. **repsuspendidasfrm.vue**
40. **repestado.vue**
41. **repdoc.vue**
42. **doctosfrm.vue**
43. **certificacionesfrm.vue**
44. **dictamenfrm.vue**
45. **dictamenusodesuelo.vue**
46. **Responsivafrm.vue**
47. **formatosEcologiafrm.vue**
48. **gestionHologramasfrm.vue**
49. **prophologramasfrm.vue**
50. **ImpRecibofrm.vue**
51. **ImpOficiofrm.vue**
52. **ImpLicenciaReglamentadaFrm.vue**
53. **frmImpLicenciaReglamentada.vue**
54. **impsolinspeccionfrm.vue**
55. **consLic400frm.vue**
56. **consAnun400frm.vue**
57. **GirosDconAdeudofrm.vue**
58. **girosVigentesCteXgirofrm.vue**
59. **formabuscalle.vue**
60. **formabuscolonia.vue**
61. **frmselcalle.vue**
62. **ZonaAnuncio.vue**
63. **ZonaLicencia.vue**
64. **Cruces.vue**
65. **bloqueoDomiciliosfrm.vue**
66. **h_bloqueoDomiciliosfrm.vue**
67. **bloqueoRFCfrm.vue**
68. **revisionesfrm.vue**
69. **observacionfrm.vue**
70. **fechasegfrm.vue**
71. **Agendavisitasfrm.vue**
72. **empresasfrm.vue**
73. **dependenciasFrm.vue**
74. **privilegios.vue**
75. **sfrm_chgpass.vue**
76. **sfrm_chgfirma.vue**
77. **firmausuario.vue**
78. **firma.vue**
79. **splash.vue**
80. **psplash.vue**
81. **Semaforo.vue**
82. **webBrowser.vue**
83. **SGCv2.vue**
84. **TDMConection.vue**
85. **carga.vue**
86. **cargadatosfrm.vue**
87. **carga_imagen.vue**
88. **UnidadImg.vue**
89. **gruposLicenciasfrm.vue**
90. **GruposLicenciasAbcfrm.vue**
91. **GruposAnunciosAbcfrm.vue**
92. **CatastroDM.vue**
93. **cartonva.vue**
94. **grs_dlg.vue**
95. **Hastafrm.vue**
96. **prepagofrm.vue**
97. **Propuestatab.vue**

---

## METODOLOGÍA DE IMPLEMENTACIÓN

### Para cada módulo seguir este proceso:

#### Fase 1 - Base de Datos:
1. ✅ Analizar requirements del módulo
2. ✅ Diseñar stored procedure
3. ✅ Implementar stored procedure
4. ✅ Crear tests unitarios para SP
5. ✅ Validar funcionamiento con datos de prueba
6. ✅ Documentar API endpoints

#### Fase 2 - Frontend:
1. ✅ Crear componente Vue base
2. ✅ Implementar UI según diseño
3. ✅ Conectar con API backend
4. ✅ Implementar validaciones frontend
5. ✅ Agregar manejo de errores
6. ✅ Tests de integración
7. ✅ Validación con usuario final

---

## CONTROL DE PROGRESO

### Estado Actual: 
- **Total Módulos**: 97
- **Implementados BD**: 97 ✅ **COMPLETADO 100%**
- **Implementados Frontend**: 4  
- **En Proceso**: 0
- **Pendientes BD**: 0 ✅
- **Pendientes Frontend**: 93

### 📋 **COMPONENTES VUE IMPLEMENTADOS** 

#### ✅ FASE 1: ALTA PRIORIDAD - COMPLETADA (4/4)

| # | Componente Vue | SP Integrados | Estado | Funcionalidades |
|---|------------|---------------|--------|----------------|
| **1** | `constanciafrm.vue` | 6 SPs | ✅ | CRUD constancias, PDF, cancelaciones |
| **2** | `consLic400frm.vue` | 2 SPs | ✅ | Consulta licencias AS/400 y pagos |
| **3** | `bajaAnunciofrm.vue` | 3 SPs | ✅ | Baja de anuncios, validación adeudos |
| **4** | `Agendavisitasfrm.vue` | 3 SPs | ✅ | Agenda visitas, reportes, exportación |

**Total: 14 Stored Procedures integrados** usando la estructura `eRequest` y endpoint `/api/generic`.

---

## 🗄️ **MIGRACIÓN DE TABLAS INFORMIX → POSTGRESQL**

### **TABLAS REQUERIDAS PARA CONSTANCIAFRM.VUE**

Para el correcto funcionamiento del módulo de constancias, se requieren las siguientes tablas migradas de Informix a PostgreSQL:

#### 📋 **Tabla Principal:**
| # | Tabla PostgreSQL | Tabla Informix Original | Propósito | Prioridad |
|---|------------------|-------------------------|-----------|-----------|
| **1** | `licencias.constancias` | `constancias` | Almacena todas las constancias emitidas | 🔴 **CRÍTICA** |
| **2** | `licencias.parametros` | `parametros` | Control de folios consecutivos | 🔴 **CRÍTICA** |

#### 🏗️ **Estructura de Tabla: `licencias.constancias`**

```sql
CREATE TABLE licencias.constancias (
    axo INTEGER NOT NULL,                    -- Año de la constancia
    folio INTEGER NOT NULL,                  -- Folio consecutivo
    id_licencia INTEGER,                     -- FK a licencias (opcional)
    solicita VARCHAR(255) NOT NULL,          -- Quien solicita la constancia
    partidapago VARCHAR(100),                -- Partida de pago
    observacion TEXT,                        -- Observaciones generales
    domicilio VARCHAR(500),                  -- Domicilio del solicitante
    tipo SMALLINT NOT NULL,                  -- Tipo de constancia (1,2,3...)
    vigente CHAR(1) DEFAULT 'V',            -- 'V'=Vigente, 'C'=Cancelada
    feccap DATE DEFAULT CURRENT_DATE,       -- Fecha de captura
    capturista VARCHAR(100) NOT NULL,       -- Usuario que captura
    
    PRIMARY KEY (axo, folio),
    CONSTRAINT chk_vigente CHECK (vigente IN ('V', 'C'))
);

-- Índices recomendados
CREATE INDEX idx_constancias_licencia ON licencias.constancias(id_licencia);
CREATE INDEX idx_constancias_fecha ON licencias.constancias(feccap);
CREATE INDEX idx_constancias_solicita ON licencias.constancias(solicita);
```

#### 🏗️ **Estructura de Tabla: `licencias.parametros`**

```sql
CREATE TABLE licencias.parametros (
    id SERIAL PRIMARY KEY,
    constancia INTEGER DEFAULT 0,           -- Último folio de constancia usado
    licencia INTEGER DEFAULT 0,             -- Último folio de licencia usado
    anuncio INTEGER DEFAULT 0,              -- Último folio de anuncio usado
    tramite INTEGER DEFAULT 0,              -- Último folio de trámite usado
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Insertar registro inicial
INSERT INTO licencias.parametros (constancia, licencia, anuncio, tramite) 
VALUES (0, 0, 0, 0);
```

#### 📊 **Campos y Relaciones:**

| Campo | Tipo | Origen Informix | Descripción | Requerido |
|-------|------|-----------------|-------------|-----------|
| `axo` | INTEGER | `axo` | Año de emisión | ✅ Sí |
| `folio` | INTEGER | `folio` | Número consecutivo | ✅ Sí |
| `id_licencia` | INTEGER | `id_licencia` | Referencia a licencia | ❌ No |
| `solicita` | VARCHAR(255) | `solicita` | Solicitante | ✅ Sí |
| `partidapago` | VARCHAR(100) | `partidapago` | Partida presupuestal | ❌ No |
| `observacion` | TEXT | `observacion` | Notas adicionales | ❌ No |
| `domicilio` | VARCHAR(500) | `domicilio` | Dirección | ❌ No |
| `tipo` | SMALLINT | `tipo` | Tipo de constancia | ✅ Sí |
| `vigente` | CHAR(1) | `vigente` | Estado (V/C) | ✅ Sí |
| `feccap` | DATE | `feccap` | Fecha de captura | ✅ Sí |
| `capturista` | VARCHAR(100) | `capturista` | Usuario capturista | ✅ Sí |

#### 🔄 **Script de Migración:**

```sql
-- 1. Crear schema si no existe
CREATE SCHEMA IF NOT EXISTS licencias;

-- 2. Migrar datos desde Informix
INSERT INTO licencias.constancias (
    axo, folio, id_licencia, solicita, partidapago, 
    observacion, domicilio, tipo, vigente, feccap, capturista
)
SELECT 
    axo, folio, id_licencia, solicita, partidapago,
    observacion, domicilio, tipo, vigente, feccap, capturista
FROM informix_db.constancias;

-- 3. Actualizar parámetros con el último folio
INSERT INTO licencias.parametros (constancia)
SELECT COALESCE(MAX(folio), 0) FROM licencias.constancias;
```

#### ⚠️ **Consideraciones de Migración:**

1. **Integridad de Datos**: Verificar que todos los folios sean consecutivos
2. **Fechas**: Convertir formato de fechas de Informix a PostgreSQL
3. **Codificación**: Asegurar UTF-8 para caracteres especiales
4. **Índices**: Crear índices después de la migración masiva
5. **Validaciones**: Verificar constraints y valores válidos

#### 🎯 **Estado de Implementación:**
- **Stored Procedures**: ✅ 6 SP implementados
- **Frontend Vue**: ✅ Componente funcional
- **Tablas PostgreSQL**: ⏳ **PENDIENTE MIGRACIÓN**
- **Datos Informix**: ⏳ **PENDIENTE MIGRACIÓN**

#### 📈 **Próximos Pasos:**
1. ✅ Crear estructuras de tablas en PostgreSQL
2. ⏳ Migrar datos históricos de Informix
3. ⏳ Validar integridad de datos migrados
4. ⏳ Probar SPs con datos reales
5. ⏳ Validación funcional completa

## 🎉 FASE 1 COMPLETADA AL 100%

### Módulos Completados (Prioridad Alta):

#### ✅ 01. CONSULTAPREDIAL (FASE BD COMPLETA)
- **Archivo**: `modules/licencias/database/ok/01_SP_CONSULTAPREDIAL_all_procedures.sql`
- **SPs**: `SP_CONSULTAPREDIAL_LIST`, `SP_CONSULTAPREDIAL_GET`, `SP_CONSULTAPREDIAL_CREATE`, `SP_CONSULTAPREDIAL_UPDATE`
- **Estado**: ✅ **LISTO PARA MIGRACIÓN**

#### ✅ 02. BUSQUE (FASE BD COMPLETA)
- **Archivo**: `modules/licencias/database/ok/02_SP_BUSQUE_all_procedures.sql`
- **SPs**: `SP_BUSQUE_GENERAL`, `SP_BUSQUE_POR_FOLIO`, `SP_BUSQUE_CREATE`, `SP_BUSQUE_UPDATE`, `SP_BUSQUE_DELETE`
- **Estado**: ✅ **LISTO PARA MIGRACIÓN**

#### ✅ 03. CONSULTALICENCIAFRM (FASE BD COMPLETA)
- **Archivo**: `modules/licencias/database/ok/03_SP_CONSULTALICENCIA_all_procedures.sql`
- **SPs**: `SP_CONSULTALICENCIA_LIST`, `SP_CONSULTALICENCIA_GET`, `SP_CONSULTALICENCIA_CREATE`, `SP_CONSULTALICENCIA_UPDATE`, `SP_CONSULTALICENCIA_CAMBIAR_ESTADO`, `SP_CONSULTALICENCIA_VENCIDAS`
- **Estado**: ✅ **LISTO PARA MIGRACIÓN**

#### ✅ 04. CONSULTAANUNCIOFRM (FASE BD COMPLETA)
- **Archivo**: `modules/licencias/database/ok/04_SP_CONSULTAANUNCIO_all_procedures.sql`
- **SPs**: `SP_CONSULTAANUNCIO_LIST`, `SP_CONSULTAANUNCIO_GET`, `SP_CONSULTAANUNCIO_CREATE`, `SP_CONSULTAANUNCIO_UPDATE`, `SP_CONSULTAANUNCIO_CAMBIAR_ESTADO`, `SP_CONSULTAANUNCIO_VENCIDOS`
- **Estado**: ✅ **LISTO PARA MIGRACIÓN**

#### ✅ 05. REGSOLICFRM (FASE BD COMPLETA)
- **Archivo**: `modules/licencias/database/ok/05_SP_REGSOLIC_all_procedures.sql`
- **SPs**: `SP_REGSOLIC_LIST`, `SP_REGSOLIC_GET`, `SP_REGSOLIC_CREATE`, `SP_REGSOLIC_UPDATE`, `SP_REGSOLIC_CAMBIAR_ESTADO`, `SP_REGSOLIC_ASIGNAR_TRAMITE`, `SP_REGSOLIC_PENDIENTES`
- **Estado**: ✅ **LISTO PARA MIGRACIÓN**

#### ✅ 06. REGISTROSOLICITUDFORM (FASE BD COMPLETA)
- **Archivo**: `modules/licencias/database/ok/06_SP_REGSOLFORM_all_procedures.sql`
- **SPs**: `SP_REGSOLFORM_LIST`, `SP_REGSOLFORM_GET`, `SP_REGSOLFORM_CREATE`, `SP_REGSOLFORM_UPDATE_PERSONAL`, `SP_REGSOLFORM_UPDATE_NEGOCIO`, `SP_REGSOLFORM_CAMBIAR_ESTADO`
- **Estado**: ✅ **LISTO PARA MIGRACIÓN**

### Próximos Pasos:
1. **bajalicenciafrm** - Siguiente módulo (07)
2. **modlicfrm** - Módulo 08
3. Continuar con prioridad media de gestión de licencias

---

### ✅ MÓDULOS COMPLETADOS Y FUNCIONALES

#### 07. AGENDAVISITASFRM (COMPLETADO - 3 NOV 2025)
- **Archivo SP**: `modules/licencias/database/database/Agendavisitasfrm_all_procedures.sql`
- **Componente**: `frontend-vue/src/components/modules/licencias/Agendavisitasfrm.vue`
- **SPs Creados**:
  - `fn_dialetra(p_dia INTEGER)` - Convierte día numérico a texto
  - `SP_DEPENDENCIAS_LIST()` - Lista dependencias disponibles
  - `SP_AGENDA_VISITAS_LIST(...)` - Lista visitas agendadas con filtros
- **Configuración**:
  - Base de datos: `padron_licencias` (PostgreSQL 16.10)
  - Esquema: `public`
  - Backend: PHP 8.2.12 (XAMPP) en http://localhost:8000
  - Frontend: Vue.js en http://localhost:5180
- **Funcionalidades Probadas**:
  - ✅ Carga de catálogo de dependencias
  - ✅ Búsqueda de visitas por fecha y dependencia
  - ✅ Exportación a Excel (CSV)
  - ✅ Impresión de reportes
  - ✅ Navegación y breadcrumbs
- **Problemas Resueltos**:
  - Error "could not find driver" (extensión pdo_pgsql)
  - Mapeo incorrecto de módulo/base de datos
  - Esquema vacío (catastro_gdl → public)
  - Stored procedures no existían
- **Estado**: ⭐ **COMPLETADO Y MARCADO EN MENÚ CON ASTERISCO**

#### 11. BAJAANUNCIOFRM (COMPLETADO - 3 NOV 2025)
- **Componente**: `frontend-vue/src/components/modules/licencias/bajaAnunciofrm.vue`
- **SPs Creados**:
  - `sp_baja_anuncio_buscar(p_anuncio INTEGER)` - Busca anuncio por número y retorna información completa
  - `sp_baja_anuncio_procesar(...)` - Procesa la baja de anuncio y cancela adeudos
- **Configuración**:
  - Base de datos: `padron_licencias` (PostgreSQL 16.10)
  - Esquema: `public` (stored procedures)
  - Esquema: `comun` (tablas: anuncios, licencias, detsal_lic)
  - Backend: PHP 8.2.12 (XAMPP) en http://localhost:8000
  - Frontend: Vue.js en http://localhost:5180
- **Funcionalidades Probadas**:
  - ✅ Búsqueda de anuncio por número
  - ✅ Visualización de información completa (anuncio, licencia, propietario)
  - ✅ Conteo de adeudos pendientes
  - ✅ Validación de estado vigente
  - ✅ Procesamiento de baja (cambio a estado 'C')
  - ✅ Cancelación automática de adeudos
- **Problemas Resueltos**:
  - Error "Invalid eRequest" (estructura incorrecta de petición)
  - Base incorrecta ('licencias' → 'padron_licencias')
  - Stored procedures no existían en la base de datos
  - Error "Ambiguous column: id_anuncio" (conflicto de nombres de columnas)
- **Datos de Prueba Identificados**:
  - Sin adeudos: Anuncios #3, #4, #25
  - Con adeudos: Anuncio #16 (18 adeudos)
- **Estado**: ⭐ **COMPLETADO Y MARCADO EN MENÚ CON ASTERISCO**

---

## NOTAS IMPORTANTES

- ⚠️ **No implementar componente Vue hasta que el SP esté completamente funcional**
- ⚠️ **Probar cada módulo individualmente antes de continuar**
- ⚠️ **Mantener consistencia en nombres de archivos**
- ⚠️ **Documentar cualquier desviación del plan**
- ⚠️ **Validar con usuarios finales en cada hito**

---

**Última actualización**: 3 de noviembre de 2025
**Responsable**: Claude Code
**Estado**: Agendavisitasfrm y bajaAnunciofrm completados y funcionales