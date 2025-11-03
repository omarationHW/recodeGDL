# 📋 Plan Ejecutivo - 2 Desarrolladores Frontend
## 5 Días - 9 Sistemas - 598 Archivos Vue.js

**📄 Referencias:**
- `INVENTARIO_COMPLETO_VUE.md` - Lista detallada de todos los archivos
- `PROCESO_RECODIFICACION_6_AGENTES.md` - Proceso detallado de recodificación

---

## 📊 Resumen

| Aspecto | Detalle |
|---------|---------|
| **Duración** | 5 días (Mar 4 Nov - Lun 10 Nov 2025), 8 hrs/día |
| **Fecha Inicio** | Martes 4 de Noviembre 2025 |
| **Fecha Fin** | Lunes 10 de Noviembre 2025 |
| **Equipo** | 2 Devs + Claude Code (6 Agentes) |
| **Backend** | ✅ Laravel completo y funcional |
| **API** | ✅ Servicio genérico ÚNICO: api.service.js |
| **Base de Datos** | 9 BD individuales + 1 BD común |
| **Stack** | Vue 3, Bootstrap, Axios, municipal-theme.css |
| **Total Archivos** | 598 archivos Vue existentes |
| **Inventario** | INVENTARIO_COMPLETO_VUE.md |
| **Proceso** | 6 Agentes por componente |

**⚠️ IMPORTANTE:**
- ❌ NO crear servicios individuales por sistema (distribucion.service.js, cementerios.service.js, etc.)
- ✅ SOLO usar el servicio API genérico: `services/api.service.js`
- ✅ Todos los componentes Vue importan: `import { apiService } from '@/services/api.service'`

---

## 🗄️ Arquitectura de Base de Datos

### Bases de Datos por Sistema (Esquema: public)
| Sistema | Base de Datos | Esquema |
|---------|---------------|---------|
| Distribución | distribucion_db | public |
| Cementerios | cementerios_db | public |
| Aseo Contratado | aseo_contratado_db | public |
| Mercados | mercados_db | public |
| Otras Obligaciones | otras_obligaciones_db | public |
| Padrón Licencias | padron_licencias_db | public |
| Multas y Reglamentos | multas_reglamentos_db | public |
| Estacionamiento Exclusivo | estacionamiento_exclusivo_db | public |
| Estacionamiento Público | estacionamiento_publico_db | public |

### Base de Datos Común
- **Base de datos:** `padron_licencias`
- **Esquema:** `comun`
- **Propósito:** Catálogos, configuraciones y datos compartidos

---

## 🔄 Proceso de 6 Agentes (Por cada componente Vue)

| Agente | Responsabilidad | Salida |
|--------|-----------------|--------|
| 1. Orquestador | Administrar flujo y dependencias | Orden de ejecución |
| 2. SP (Stored Procedures) | Migrar SP a INFORMIX | SP funcionales en BD |
| 3. Vue (Integración) | Implementar SP en componente | Componente funcional |
| 4. Bootstrap/UX | Aplicar estilos y UX | UI completa |
| 5. Validador Global | Revisar todo el trabajo | Componente validado |
| 6. Limpieza | Limpiar y documentar | Componente completo ✅ |

**📄 Ver detalles completos en:** `PROCESO_RECODIFICACION_6_AGENTES.md`

---

## 📁 Estructura de Archivos (NO MOVER NI BORRAR)

### Template Base (NO TOCAR)
```
RefactorX/Base/[modulo]/
├── database/ok/              → SPs originales
├── docs/
│   └── CONTROL_IMPLEMENTACION_VUE.md
└── *.vue                     → Archivos Vue origen
```

### Archivos Destino
```
RefactorX/FrontEnd/src/views/modules/[modulo]/
└── [archivo].vue             → Componentes finales
```

### Archivos Originales Delphi
```
C:\Sistemas\RefactorX\Guadalajara\Originales\Code\197\aplicaciones\Ingresos\[modulo]/
├── *.pas   → Lógica de negocio
├── *.dfm   → Diseño de formularios
└── *.dcu   → Unidades compiladas
```

---

## 🔌 Servicio API Genérico (Único para todos los sistemas)

### services/api.service.js
```javascript
import axios from 'axios'

const API_BASE_URL = process.env.VUE_APP_API_URL || 'http://localhost:8000/api'

export const apiService = {
  /**
   * Ejecutar Stored Procedure genérico
   * @param {string} database - Nombre de la base de datos
   * @param {string} schema - Esquema (public o comun)
   * @param {string} spName - Nombre del SP
   * @param {object} params - Parámetros del SP
   */
  async callSP(database, schema, spName, params = {}) {
    try {
      const response = await axios.post(`${API_BASE_URL}/sp/execute`, {
        database,
        schema,
        sp_name: spName,
        params
      })
      return response.data
    } catch (error) {
      console.error(`Error calling SP ${spName}:`, error)
      throw error
    }
  },

  /**
   * Ejecutar SP de un sistema específico (esquema public)
   * @param {string} systemName - Nombre del sistema
   * @param {string} spName - Nombre del SP
   * @param {object} params - Parámetros
   */
  async executeSystemSP(systemName, spName, params = {}) {
    const database = `${systemName}_db`
    const schema = 'public'
    return this.callSP(database, schema, spName, params)
  },

  /**
   * Ejecutar SP de datos comunes (esquema comun)
   * @param {string} spName - Nombre del SP
   * @param {object} params - Parámetros
   */
  async executeCommonSP(spName, params = {}) {
    const database = 'padron_licencias'
    const schema = 'comun'
    return this.callSP(database, schema, spName, params)
  }
}
```

### Uso en componentes Vue:
```vue
<script setup>
import { apiService } from '@/services/api.service'

// Llamar SP del sistema específico
async function loadData() {
  const result = await apiService.executeSystemSP(
    'estacionamiento_publico',
    'sp_get_folios',
    { fecha_inicio: '2025-01-01', fecha_fin: '2025-12-31' }
  )
}

// Llamar SP de datos comunes
async function loadCatalogos() {
  const result = await apiService.executeCommonSP(
    'sp_get_catalogos',
    { tipo: 'estados' }
  )
}
</script>
```

---

## 🎯 Distribución de Trabajo

**Proceso:** Cada componente Vue pasa por los 6 agentes (ver `PROCESO_RECODIFICACION_6_AGENTES.md`)

### Developer 1 - Sistemas Simples/Medios (308 archivos)
| Día | Fecha | Sistema | Archivos | Proceso 6 Agentes | Tiempo |
|-----|-------|---------|----------|-------------------|--------|
| Día 1 | Mar 4 Nov AM | Distribución | 15 (crear) | Orq→SP→Vue→UX→Val→Limp | 8-12h |
| Día 1 | Mar 4 Nov PM | Cementerios | 36 | Lotes de 5 archivos | 13-18h |
| Día 2 | Mié 5 Nov | Aseo Contratado | 103 | Lotes de 5 archivos | 8-18h |
| Día 3 | Jue 6 Nov AM | Mercados (parte 1) | 54 | Lotes de 5 archivos | 8-13h |
| Día 3 | Jue 6 Nov PM | Mercados (parte 2) | 53 | Lotes de 5 archivos | 14-18h |
| Día 4 | Vie 7 Nov | Otras Obligaciones | 27 | Lotes de 5 archivos | 8-18h |
| Día 5 | Lun 10 Nov | Est. Público (50%) | 30 | Apoyo Dev2 | 8-18h |

### Developer 2 - Sistemas Complejos (295 archivos)
| Día | Fecha | Sistema | Archivos | Proceso 6 Agentes | Tiempo |
|-----|-------|---------|----------|-------------------|--------|
| Día 3 | Jue 6 Nov | Padrón Licencias | 97 | Lotes de 5 archivos | 8-18h |
| Día 4 | Vie 7 Nov AM | Multas (parte 1) | 53 | Lotes de 5 archivos | 8-13h |
| Día 4 | Vie 7 Nov PM | Multas (parte 2) | 53 | Lotes de 5 archivos | 14-18h |
| Día 4 | Vie 7 Nov Noche | Est. Exclusivo | 61 | Lotes de 5 archivos | 19-22h (extra) |
| Día 5 | Lun 10 Nov | Est. Público (50%) | 31 | Con Dev1 | 8-18h |

**NOTA:**
- Procesar en lotes de 5 archivos .vue por iteración
- Dev1 apoya a Dev2 desde Jueves 6 Nov PM
- Cada archivo pasa por los 6 agentes: Orquestador → SP → Vue → UX → Validador → Limpieza
- Control de avance en `CONTROL_IMPLEMENTACION_VUE.md` de cada módulo

---

# 📅 DÍA 1 - MARTES 4 NOVIEMBRE 2025

## 8:00-8:30 AM | Setup Inicial (Ambos)

```bash
# Git
cd C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL
git pull origin main
git checkout -b feature/frontend-week1

# Backend check
curl http://localhost:8000/api/health

# Frontend
cd frontend
npm install
npm run dev  # Debe abrir http://localhost:5173

# Claude Code ready
```

---

## 8:30-9:30 AM | Preparación

### Dev1: Verificar Bases de Datos
```bash
# Verificar conectividad a las 9 BD individuales + 1 común
psql -U postgres -l | grep "_db"

# Debería mostrar:
# - distribucion_db
# - cementerios_db
# - aseo_contratado_db
# - mercados_db
# - otras_obligaciones_db
# - padron_licencias_db (sistema)
# - multas_reglamentos_db
# - estacionamiento_exclusivo_db
# - estacionamiento_publico_db
# - padron_licencias (común - esquema: comun)

# Verificar esquemas
psql -U postgres -d padron_licencias
\dn  # Debe mostrar esquemas: public y comun
```

### Dev2: Crear Servicio API Genérico
```bash
cd RefactorX/FrontEnd/src
mkdir -p services

# Crear archivo services/api.service.js
```

**Claude Code Prompt para Dev2:**
```
Crea el servicio API genérico en services/api.service.js según la especificación
del PLAN_EJECUTIVO_2_DEVS_FRONTEND.md sección "Servicio API Genérico".

El servicio debe tener 3 métodos:
1. callSP(database, schema, spName, params) - Genérico
2. executeSystemSP(systemName, spName, params) - Para sistemas (esquema public)
3. executeCommonSP(spName, params) - Para datos comunes (esquema comun)

Usa axios y manejo de errores completo.
```

### Ambos: Leer Documentación
```bash
# Leer procesos completos
- INVENTARIO_COMPLETO_VUE.md
- PROCESO_RECODIFICACION_6_AGENTES.md
- PLAN_EJECUTIVO_2_DEVS_FRONTEND.md
```
```

---

## 9:30 AM-12:00 PM | Sistema 1: DISTRIBUCIÓN (15 forms)

### Ambos trabajando en paralelo

**Paso 1 - Análisis con Claude:**
```
Analiza archivos Delphi de Distribución:
[PEGAR archivos .pas/.dfm de RefactorX/Base/distribucion/]

Identifica:
- Formularios y campos
- Tablas BD usadas
- Validaciones
- Endpoints backend necesarios

Genera lista de componentes Vue a crear.
```

**Paso 2 - Servicio API:**
```javascript
// services/distribucion.service.js
import api from './api'

export const distribucionService = {
  getAll: async (params) => api.get('/distribucion', { params }),
  getById: async (id) => api.get(`/distribucion/${id}`),
  create: async (data) => api.post('/distribucion', data),
  update: async (id, data) => api.put(`/distribucion/${id}`, data),
  delete: async (id) => api.delete(`/distribucion/${id}`),
  buscar: async (criterio) => api.post('/distribucion/buscar', criterio)
}
```

**Paso 3 - Componentes con Claude:**
```
Convierte formularios Delphi a Vue 3:
[PEGAR .pas/.dfm]

Genera:
- DistribucionList.vue (tabla con paginación)
- DistribucionForm.vue (alta/edición)
- DistribucionSearch.vue (búsqueda avanzada)

Requisitos:
- <script setup> Composition API
- PrimeVue DataTable
- VeeValidate validaciones
- Integración con distribucionService
- Responsive
```

**Paso 4 - Rutas:**
```javascript
// modules/distribucion/routes.js
export default [
  {
    path: '/distribucion',
    component: () => import('./views/DistribucionLayout.vue'),
    children: [
      { path: '', component: () => import('./views/DistribucionList.vue') },
      { path: 'nuevo', component: () => import('./views/DistribucionForm.vue') }
    ]
  }
]
```

---

## 1:00-4:00 PM | Sistema 2: CEMENTERIOS (20 forms)

**Misma metodología:**
1. Analizar con Claude Code
2. Crear cementerios.service.js
3. Generar componentes Vue
4. Configurar rutas
5. Testing básico

**División:**
- Dev1: Forms 1-10 (Lotes, nichos, asignaciones)
- Dev2: Forms 11-20 (Servicios, contratos, reportes)

---

## 4:00-7:30 PM | Sistema 3: ASEO CONTRATADO (25 forms)

**División:**
- Dev1: Forms 1-13 (Contratos, cobranza, pagos)
- Dev2: Forms 14-25 (Reportes, búsquedas, estadísticas)

---

## 7:30-8:00 PM | Commit Día 1

```bash
npm run build  # Verificar sin errores
git add .
git commit -m "Add: Día 1 - Distribución, Cementerios, Aseo (60 forms)"
git push origin feature/frontend-week1
```

**✅ Progreso: 60/470 = 13%**

---

# 📅 DÍA 2 - MARTES

## 8:00 AM-1:00 PM | Sistema 4: MERCADOS (35 forms)

### Componentes Clave:

**Servicios:**
```javascript
// services/mercados.service.js
export const mercadosService = {
  puestos: {
    getAll: async () => api.get('/mercados/puestos'),
    crear: async (data) => api.post('/mercados/puestos', data)
  },
  comerciantes: {
    getAll: async () => api.get('/mercados/comerciantes'),
    registrar: async (data) => api.post('/mercados/comerciantes', data)
  },
  asignaciones: {
    asignarPuesto: async (data) => api.post('/mercados/asignaciones', data)
  },
  pagos: {
    registrar: async (data) => api.post('/mercados/pagos', data),
    getAdeudos: async (id) => api.get(`/mercados/comerciantes/${id}/adeudos`)
  }
}
```

**División:**
- Dev1: Forms 1-18 (Puestos, comerciantes, asignaciones, pagos)
- Dev2: Forms 19-35 (Reportes, estadísticas, consultas)

---

## 1:00-8:00 PM | Sistema 5: OTRAS OBLIGACIONES (40 forms)

### Módulos:

**1. Giros (20 forms) - Dev1:**
```javascript
// services/giros.service.js
export const girosService = {
  getAll: async (params) => api.get('/giros', { params }),
  crear: async (data) => api.post('/giros', data),
  actualizar: async (id, data) => api.put(`/giros/${id}`, data),
  eliminar: async (id) => api.delete(`/giros/${id}`),
  calcularAdeudos: async (id) => api.get(`/giros/${id}/adeudos`),
  facturar: async (id, data) => api.post(`/giros/${id}/facturar`, data)
}
```

**Componentes:**
- GNuevos.vue
- GConsulta.vue
- GActualiza.vue
- GBaja.vue
- GAdeudos.vue
- GFacturacion.vue
- GReportes.vue

**2. Rubros (20 forms) - Dev2:**
Mismo patrón que Giros:
- RNuevos.vue
- RConsulta.vue
- RActualiza.vue
- etc.

**Store Pinia compartido:**
```javascript
// stores/otras-obligaciones.store.js
import { defineStore } from 'pinia'

export const useOtrasObligacionesStore = defineStore('otras-obligaciones', {
  state: () => ({
    giros: [],
    rubros: [],
    catalogos: {}
  }),
  actions: {
    async loadGiros() {
      this.giros = await girosService.getAll()
    },
    async loadRubros() {
      this.rubros = await rubrosService.getAll()
    }
  }
})
```

---

## 7:30-8:00 PM | Commit Día 2

```bash
npm run build
git add .
git commit -m "Add: Día 2 - Mercados, Otras Obligaciones (75 forms)"
git push origin feature/frontend-week1
```

**✅ Progreso: 135/470 = 29%**

---

# 📅 DÍA 3 - MIÉRCOLES

## Sistema 6: PADRÓN DE LICENCIAS (60 forms)

**AMBOS DEVS TRABAJANDO JUNTOS**

### 8:00-9:00 AM | Análisis

**Claude Code:**
```
Analiza sistema Padrón de Licencias (60 formularios):
[PEGAR archivos RefactorX/Base/padron_licencias/]

Identifica:
- Entidades: Licencias, Anuncios, Trámites, Giros
- Relaciones BD
- Flujos de trabajo
- Reportes principales

Propón arquitectura de componentes Vue.
```

### 9:00 AM-8:00 PM | Implementación

**División:**

#### Dev1 - Módulos Core (30 forms):
1. **Licencias (10)**
   - LicenciasList.vue
   - LicenciaForm.vue
   - LicenciaDetalle.vue

2. **Trámites (10)**
   - TramiteWizard.vue (multi-step)
   - TramitesList.vue
   - DocumentosUpload.vue

3. **Anuncios (10)**
   - AnuncioForm.vue
   - AnunciosList.vue
   - ZonasAnuncios.vue

#### Dev2 - Módulos Soporte (30 forms):
4. **Consultas (10)**
   - BusquedaAvanzada.vue
   - ConsultaEstatus.vue
   - Historial.vue

5. **Pagos (10)**
   - PagosForm.vue
   - AdeudosConsulta.vue
   - DescuentosForm.vue
   - Facturacion.vue

6. **Reportes (10)**
   - ReportesLicencias.vue
   - EstadisticasGiros.vue
   - DashboardLicencias.vue

### Servicio Principal:

```javascript
// services/licencias.service.js
export const licenciasService = {
  // CRUD
  getAll: async (filters) => api.get('/licencias', { params: filters }),
  getById: async (id) => api.get(`/licencias/${id}`),
  crear: async (data) => api.post('/licencias', data),
  actualizar: async (id, data) => api.put(`/licencias/${id}`, data),

  // Operaciones
  renovar: async (id, data) => api.post(`/licencias/${id}/renovar`, data),
  suspender: async (id) => api.post(`/licencias/${id}/suspender`),

  // Pagos
  registrarPago: async (id, data) => api.post(`/licencias/${id}/pagos`, data),
  getAdeudos: async (id) => api.get(`/licencias/${id}/adeudos`),
  aplicarDescuento: async (id, data) => api.post(`/licencias/${id}/descuentos`, data),

  // Reportes
  getReporte: async (filtros) => api.post('/licencias/reportes', filtros)
}
```

---

## 7:30-8:00 PM | Commit Día 3

```bash
npm run build
git add .
git commit -m "Add: Día 3 - Padrón Licencias completo (60 forms)"
git push origin feature/frontend-week1
```

**✅ Progreso: 195/470 = 41%**

---

# 📅 DÍA 4 - JUEVES

## 8:00 AM-5:00 PM | Sistema 7: MULTAS Y REGLAMENTOS (90 forms)

### Análisis (8:00-8:30 AM):

**Claude Code:**
```
Analiza Multas y Reglamentos (90 formularios):
[PEGAR archivos RefactorX/Base/multas_reglamentos/vue/]

Módulos:
- Captura de multas
- Requerimientos (workflow 400 días)
- Ejecutores
- Pagos
- Descuentos
- Reportes

Propón arquitectura modular.
```

### División:

#### Dev1 (45 forms):
1. **Captura Multas (15)**
   - MultasForm.vue
   - MultasList.vue
   - MultasConsulta.vue

2. **Ejecutores (15)**
   - EjecutoresABM.vue
   - AsignacionEjecutor.vue
   - PrenominaEjecutor.vue

3. **Descuentos (15)**
   - DescuentosForm.vue
   - AutorizacionDescuento.vue
   - ReportesDescuentos.vue

#### Dev2 (45 forms):
1. **Requerimientos (20)**
   - RequerimientosList.vue
   - WorkflowRequerimiento.vue (timeline)
   - GenerarRequerimiento.vue
   - CartasRequerimiento.vue

2. **Pagos (15)**
   - PagosMultas.vue
   - ConsultaPagos.vue
   - ReporteIngresos.vue

3. **Reportes (10)**
   - ReporteEjecutores.vue
   - EstadisticasMultas.vue
   - DashboardMultas.vue

### Servicio:

```javascript
// services/multas.service.js
export const multasService = {
  // CRUD Multas
  getAll: async (filters) => api.get('/multas', { params: filters }),
  crear: async (data) => api.post('/multas', data),
  actualizar: async (id, data) => api.put(`/multas/${id}`, data),
  cancelar: async (id, motivo) => api.post(`/multas/${id}/cancelar`, { motivo }),

  // Requerimientos
  generarRequerimiento: async (multaId, tipo) =>
    api.post(`/multas/${multaId}/requerimientos`, { tipo }),
  getRequerimientos: async (multaId) =>
    api.get(`/multas/${multaId}/requerimientos`),

  // Cálculos
  calcularRecargos: async (multaId) =>
    api.post(`/multas/${multaId}/calcular-recargos`),

  // Pagos
  registrarPago: async (multaId, data) =>
    api.post(`/multas/${multaId}/pagos`, data),

  // Búsquedas
  buscarPorPlacas: async (placas) =>
    api.get(`/multas/buscar/placas/${placas}`),
  buscarPorFolio: async (folio) =>
    api.get(`/multas/buscar/folio/${folio}`)
}
```

---

## 5:00-7:30 PM | Sistema 8: ESTACIONAMIENTO EXCLUSIVO (65 forms)

**División rápida:**
- Dev1: Forms 1-33 (Ejecutores, notificaciones, folios)
- Dev2: Forms 34-65 (Requerimientos, adeudos, reportes)

**Usar patrones ya establecidos de Multas**

---

## 7:30-8:00 PM | Commit Día 4

```bash
npm run build
git add .
git commit -m "Add: Día 4 - Multas (90) + Est.Exclusivo (65) = 155 forms"
git push origin feature/frontend-week1
```

**✅ Progreso: 350/470 = 74%**

---

# 📅 DÍA 5 - VIERNES

## 8:00 AM-1:00 PM | Sistema 9: ESTACIONAMIENTO PÚBLICO (120 forms)

**SISTEMA MÁS GRANDE - MÁXIMO ESFUERZO**

### División:

#### Dev1 (60 forms):
**Módulo Folios y Propietarios**
- FoliosAlta.vue
- FoliosModificacion.vue
- FoliosConsulta.vue
- PropietariosABM.vue
- UbicacionesManagement.vue

#### Dev2 (60 forms):
**Módulo Pagos y Conciliación**
- PagosRegistro.vue
- IntegracionBanorte.vue
- ConciliacionBancaria.vue
- GeneracionArchivos.vue
- ReportesRecaudacion.vue

### Servicio:

```javascript
// services/estacionamiento-publico.service.js
export const estacionamientoPublicoService = {
  folios: {
    getAll: async (params) => api.get('/estacionamiento-publico/folios', { params }),
    crear: async (data) => api.post('/estacionamiento-publico/folios', data),
    actualizar: async (id, data) => api.put(`/estacionamiento-publico/folios/${id}`, data),
    baja: async (id) => api.post(`/estacionamiento-publico/folios/${id}/baja`)
  },

  pagos: {
    registrar: async (data) => api.post('/estacionamiento-publico/pagos', data),
    subirArchivo: async (file) => {
      const formData = new FormData()
      formData.append('archivo', file)
      return api.post('/estacionamiento-publico/pagos/cargar', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      })
    }
  },

  banorte: {
    generarArchivo: async (tipo, fecha) =>
      api.post('/estacionamiento-publico/banorte/generar', { tipo, fecha }),
    conciliar: async (data) =>
      api.post('/estacionamiento-publico/banorte/conciliar', data)
  }
}
```

---

## 1:00-3:00 PM | Testing Global

### Checklist de 9 Sistemas:

```markdown
## Distribución
- [ ] Lista carga datos
- [ ] Crear funciona
- [ ] Editar funciona
- [ ] Buscar funciona

## Cementerios
- [ ] Gestión lotes OK
- [ ] Asignación nichos OK
- [ ] Reportes funcionan

## Aseo Contratado
- [ ] Contratos OK
- [ ] Cobranza OK
- [ ] Pagos OK

## Mercados
- [ ] Puestos OK
- [ ] Comerciantes OK
- [ ] Asignaciones OK

## Otras Obligaciones
- [ ] Giros completo
- [ ] Rubros completo
- [ ] Cálculo adeudos OK

## Padrón Licencias
- [ ] CRUD licencias OK
- [ ] Trámites OK
- [ ] Anuncios OK
- [ ] Pagos OK

## Multas
- [ ] Captura multas OK
- [ ] Requerimientos OK
- [ ] Workflow funciona
- [ ] Pagos OK

## Est. Exclusivo
- [ ] Ejecutores OK
- [ ] Notificaciones OK
- [ ] Reportes OK

## Est. Público
- [ ] Folios CRUD OK
- [ ] Pagos OK
- [ ] Banorte OK
- [ ] Conciliación OK
```

---

## 3:00-5:00 PM | Corrección Bugs Críticos

**Prioridad:**
1. ❌ Bugs que impiden usar sistema
2. ⚠️ Errores de integración backend
3. 🔧 Validaciones faltantes
4. 🎨 Problemas UI críticos

**Claude Code para fixes:**
```
Tengo este error: [PEGAR ERROR]
Componente: [NOMBRE]
Código: [PEGAR CÓDIGO RELEVANTE]

Analiza y propón fix rápido sin romper nada.
```

---

## 5:00-6:30 PM | Documentación

### README.md:
```markdown
# RefactorX Frontend - Vue.js

## Sistemas
1. Distribución (15 forms)
2. Cementerios (20 forms)
3. Aseo Contratado (25 forms)
4. Mercados (35 forms)
5. Otras Obligaciones (40 forms)
6. Padrón Licencias (60 forms)
7. Multas y Reglamentos (90 forms)
8. Estacionamiento Exclusivo (65 forms)
9. Estacionamiento Público (120 forms)

**Total: 470 componentes Vue**

## Stack
- Vue 3 (Composition API)
- Pinia (State Management)
- Vue Router
- PrimeVue (UI)
- Axios (HTTP)
- Vite (Build)

## Setup
\`\`\`bash
npm install
npm run dev
\`\`\`

## Build
\`\`\`bash
npm run build
\`\`\`

## Estructura
\`\`\`
src/
├── modules/       # 9 sistemas
├── components/    # Componentes compartidos
├── services/      # APIs
├── stores/        # Pinia stores
└── router/        # Rutas
\`\`\`

## Integración Backend
URL: http://localhost:8000/api
Auth: JWT Bearer Token
```

---

## 6:30-7:30 PM | Build y Deploy

```bash
# Limpiar
npm run clean

# Build producción
npm run build
# Verificar dist/ generado

# Testing build
npm run preview

# Verificar tamaño
du -sh dist/
# Debe ser < 5MB
```

---

## 7:30-8:00 PM | Commit Final y Deploy

```bash
# Merge a main
git checkout main
git merge feature/frontend-week1 --no-ff

# Tag
git tag -a v1.0.0 -m "Frontend completo 9 sistemas"

# Push
git push origin main --tags

# Deploy (según su servidor)
scp -r dist/ usuario@servidor:/var/www/refactorx/
```

### Commit Final:

```bash
git commit -m "Release: Frontend v1.0.0 - 9 sistemas completos

✅ 470 componentes Vue funcionales
✅ 9 módulos integrados con backend
✅ Build producción sin errores
✅ Testing completo
✅ Documentación incluida

Sistemas:
- Distribución (15)
- Cementerios (20)
- Aseo Contratado (25)
- Mercados (35)
- Otras Obligaciones (40)
- Padrón Licencias (60)
- Multas y Reglamentos (90)
- Estacionamiento Exclusivo (65)
- Estacionamiento Público (120)

Stack: Vue 3 + Pinia + PrimeVue + Axios
Backend: Laravel (existente)
BD: PostgreSQL (scripts en base/)

🎉 PROYECTO COMPLETO EN 5 DÍAS"
```

---

# 🎯 Métricas Finales

| Métrica | Resultado |
|---------|-----------|
| **Sistemas** | 9/9 = 100% ✅ |
| **Formularios** | 470/470 = 100% ✅ |
| **Días** | 5/5 = 100% ✅ |
| **Build** | Sin errores ✅ |
| **Backend** | 100% integrado ✅ |
| **Deploy** | Exitoso ✅ |

---

# 📝 Prompts Claude Code Clave

## 1. Análisis Delphi
```
Analiza archivos Delphi del módulo [NOMBRE]:
[PEGAR .pas/.dfm]

Identifica:
- Formularios y campos
- Tablas BD
- Validaciones
- Lógica de negocio

Genera lista componentes Vue a crear.
```

## 2. Conversión a Vue
```
Convierte formularios Delphi a Vue 3:
[PEGAR código]

Genera:
- Componentes .vue con <script setup>
- Validaciones VeeValidate
- Integración con API backend
- PrimeVue UI
- Responsive

Backend ya existe en Laravel.
```

## 3. Servicio API
```
Crea servicio API para módulo [NOMBRE]:

Endpoints backend:
[LISTAR endpoints]

Genera [nombre].service.js con:
- Funciones async para cada endpoint
- Axios con interceptors
- Manejo de errores
- TypeScript types si es posible
```

## 4. Testing
```
Genera tests para [Componente]:
- Renderizado correcto
- Validaciones
- Llamadas API (mock)
- Manejo errores

Usa Vitest + @testing-library/vue
```

## 5. Fix Bugs
```
Tengo este error:
[ERROR]

En componente: [NOMBRE]
Código: [SNIPPET]

Analiza y propón fix sin romper otras partes.
```

---

# ✅ Checklist Diario

## Pre-Día (15 min antes)
- [ ] Claude Code activo
- [ ] Git pull
- [ ] Backend funcionando
- [ ] npm run dev OK
- [ ] Plan del día revisado

## Fin de Día (30 min)
- [ ] npm run build sin errores
- [ ] Git commit + push
- [ ] Testing básico OK
- [ ] Documentar issues
- [ ] Revisar plan siguiente día

---

# 🚀 Próximos Pasos (Post-Semana)

## Semana 2: Refinamiento
- Tests unitarios (Vitest)
- Optimización performance
- Mejorar UI/UX
- Lazy loading

## Semana 3: Features
- Exportar Excel/PDF
- Gráficas avanzadas
- Notificaciones push
- Dark mode

## Semana 4: Producción
- Capacitación usuarios
- Monitoreo
- Soporte

---

**🎉 PLAN COMPLETO - LISTO PARA EJECUTAR 🎉**
