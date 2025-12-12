<template>
  <div class="consulta-licencias-container">
    <!-- Header con título y botones -->
    <div class="page-header">
      <div class="header-content">
        <div class="title-section">
          <h1 class="page-title">
            <font-awesome-icon icon="id-card" class="title-icon" />
            Consulta de Licencias
          </h1>
          <p class="page-subtitle">Padrón de Licencias - Búsqueda avanzada</p>
        </div>
        <div class="button-group ms-auto">
          <button
            v-if="licencias.length > 0"
            class="btn-municipal-success"
            @click="exportarExcel"
            title="Exportar a Excel"
          >
            <font-awesome-icon icon="file-excel" />
            Excel
          </button>
          <button
            v-if="licencias.length > 0"
            class="btn-municipal-danger"
            @click="exportarPDF"
            title="Exportar a PDF"
          >
            <font-awesome-icon icon="file-pdf" />
            PDF
          </button>
          <button
            class="btn-municipal-primary"
            @click="buscarLicencias"
            title="Actualizar búsqueda"
          >
            <font-awesome-icon icon="sync-alt" />
            Actualizar
          </button>
          <button
            class="btn-municipal-purple"
            @click="openDocumentation"
            title="Ver documentación"
          >
            <font-awesome-icon icon="question-circle" />
            Ayuda
          </button>
        </div>
      </div>
    </div>

    <!-- Loading skeleton para estadísticas -->
    <div class="stats-grid" v-if="loadingEstadisticas">
      <div class="stat-card stat-card-loading" v-for="n in 4" :key="`loading-${n}`">
        <div class="stat-content">
          <div class="skeleton-icon"></div>
          <div class="skeleton-number"></div>
          <div class="skeleton-label"></div>
          <div class="skeleton-percentage"></div>
        </div>
      </div>
    </div>

    <!-- Cards de estadísticas -->
    <div class="stats-grid" v-else-if="estadisticas.length > 0">
      <div
        class="stat-card"
        v-for="stat in estadisticas"
        :key="stat.vigente"
        :class="`stat-${stat.vigente}`"
      >
        <div class="stat-content">
          <div class="stat-icon">
            <font-awesome-icon :icon="getVigenteIcon(stat.vigente)" />
          </div>
          <h3 class="stat-number">{{ formatNumber(stat.total) }}</h3>
          <p class="stat-label">{{ stat.descripcion }}</p>
          <small class="stat-percentage">{{ stat.porcentaje }}%</small>
        </div>
      </div>
    </div>

    <!-- Acordeón de filtros -->
    <div class="filters-section">
      <div class="filter-header" @click="showFilters = !showFilters">
        <h2 class="filter-title">
          <font-awesome-icon icon="filter" />
          Filtros de Búsqueda
        </h2>
        <font-awesome-icon
          :icon="showFilters ? 'chevron-up' : 'chevron-down'"
          class="toggle-icon"
        />
      </div>

      <transition name="slide-fade">
        <div v-show="showFilters" class="filter-content">
          <div class="filter-grid">
            <!-- Fila 1: ID Licencia, Licencia, Vigente -->
            <div class="filter-item">
              <label class="filter-label">
                <font-awesome-icon icon="hashtag" />
                ID Licencia
              </label>
              <input
                type="number"
                v-model="filtros.id_licencia"
                class="filter-input"
                placeholder="Ej: 490593"
              />
            </div>

            <div class="filter-item">
              <label class="filter-label">
                <font-awesome-icon icon="id-card" />
                Número de Licencia
              </label>
              <input
                type="number"
                v-model="filtros.licencia"
                class="filter-input"
                placeholder="Ej: 486316"
              />
            </div>

            <div class="filter-item">
              <label class="filter-label">
                <font-awesome-icon icon="check-circle" />
                Vigente
              </label>
              <select v-model="filtros.vigente" class="filter-input">
                <option value="">Todas</option>
                <option value="V">Vigente</option>
                <option value="C">Cancelado</option>
                <option value="A">Alta</option>
                <option value="B">Baja</option>
              </select>
            </div>

            <!-- Fila 2: Fechas -->
            <div class="filter-item">
              <label class="filter-label">
                <font-awesome-icon icon="calendar" />
                Fecha Desde
              </label>
              <input
                type="date"
                v-model="filtros.fecha_desde"
                class="filter-input"
              />
            </div>

            <div class="filter-item">
              <label class="filter-label">
                <font-awesome-icon icon="calendar" />
                Fecha Hasta
              </label>
              <input
                type="date"
                v-model="filtros.fecha_hasta"
                class="filter-input"
              />
            </div>

            <!-- Fila 3: Propietario, RFC -->
            <div class="filter-item">
              <label class="filter-label">
                <font-awesome-icon icon="user" />
                Propietario
              </label>
              <input
                type="text"
                v-model="filtros.propietario"
                class="filter-input"
                placeholder="Ej: Juan Pérez"
              />
            </div>

            <div class="filter-item">
              <label class="filter-label">
                <font-awesome-icon icon="id-badge" />
                RFC
              </label>
              <input
                type="text"
                v-model="filtros.rfc"
                class="filter-input"
                placeholder="Ej: XAXX010101000"
                maxlength="13"
              />
            </div>

            <!-- Fila 4: Giro, Actividad -->
            <div class="filter-item">
              <label class="filter-label">
                <font-awesome-icon icon="building" />
                ID Giro
              </label>
              <input
                type="number"
                v-model="filtros.id_giro"
                class="filter-input"
                placeholder="Ej: 1234"
              />
            </div>

            <div class="filter-item">
              <label class="filter-label">
                <font-awesome-icon icon="briefcase" />
                Actividad
              </label>
              <input
                type="text"
                v-model="filtros.actividad"
                class="filter-input"
                placeholder="Ej: Comercio"
              />
            </div>

            <!-- Fila 5: Ubicación, Colonia -->
            <div class="filter-item">
              <label class="filter-label">
                <font-awesome-icon icon="map-marker-alt" />
                Ubicación
              </label>
              <input
                type="text"
                v-model="filtros.ubicacion"
                class="filter-input"
                placeholder="Ej: Av. Juárez"
              />
            </div>

            <div class="filter-item">
              <label class="filter-label">
                <font-awesome-icon icon="home" />
                Colonia
              </label>
              <input
                type="text"
                v-model="filtros.colonia"
                class="filter-input"
                placeholder="Ej: Centro"
              />
            </div>
          </div>

          <!-- Botón de búsqueda -->
          <div class="filter-actions">
            <button class="btn-search" @click="buscarLicencias">
              <font-awesome-icon icon="search" />
              Buscar
            </button>
            <button class="btn-clear" @click="limpiarFiltros">
              <font-awesome-icon icon="times" />
              Limpiar
            </button>
          </div>
        </div>
      </transition>
    </div>

    <!-- Tabla de resultados -->
    <div class="results-section" v-if="primeraBusqueda">
      <div class="results-header">
        <h2 class="results-title">
          <font-awesome-icon icon="table" />
          Resultados de Búsqueda
        </h2>
        <span class="results-badge">{{ formatNumber(totalResultados) }} registros</span>
      </div>

      <div class="table-responsive">
        <table class="municipal-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Licencia</th>
              <th>Vigente</th>
              <th>Propietario</th>
              <th>RFC</th>
              <th>Giro</th>
              <th>Actividad</th>
              <th>Ubicación</th>
              <th>Colonia</th>
              <th>Empleados</th>
              <th>Fecha Otorg.</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="licencias.length === 0">
              <td colspan="11" class="text-center">
                <font-awesome-icon icon="info-circle" />
                No se encontraron resultados
              </td>
            </tr>
            <tr v-for="lic in licencias" :key="lic.id_licencia">
              <td :title="lic.id_licencia">{{ lic.id_licencia }}</td>
              <td :title="lic.licencia">{{ lic.licencia }}</td>
              <td>
                <span :class="`badge-vigente badge-${lic.vigente}`">
                  {{ getVigenteTexto(lic.vigente) }}
                </span>
              </td>
              <td :title="lic.propietario">{{ lic.propietario }}</td>
              <td :title="lic.rfc">{{ lic.rfc }}</td>
              <td :title="lic.descripcion_giro">{{ lic.descripcion_giro }}</td>
              <td :title="lic.actividad">{{ lic.actividad }}</td>
              <td :title="lic.ubicacion">{{ lic.ubicacion }}</td>
              <td :title="lic.colonia_ubic">{{ lic.colonia_ubic }}</td>
              <td :title="lic.num_empleados">{{ lic.num_empleados || 'N/A' }}</td>
              <td :title="lic.fecha_otorgamiento">{{ formatDate(lic.fecha_otorgamiento) }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Paginación -->
      <div class="pagination-section">
        <div class="pagination-info">
          Mostrando {{ (currentPage - 1) * itemsPerPage + 1 }} -
          {{ Math.min(currentPage * itemsPerPage, totalResultados) }} de
          {{ formatNumber(totalResultados) }} registros
        </div>
        <div class="pagination-controls">
          <button
            class="btn-page"
            :disabled="currentPage === 1"
            @click="cambiarPagina(currentPage - 1)"
          >
            <font-awesome-icon icon="chevron-left" />
            Anterior
          </button>
          <span class="page-number">Página {{ currentPage }} de {{ totalPages }}</span>
          <button
            class="btn-page"
            :disabled="currentPage === totalPages"
            @click="cambiarPagina(currentPage + 1)"
          >
            Siguiente
            <font-awesome-icon icon="chevron-right" />
          </button>
        </div>
        <div class="items-per-page">
          <label>Registros por página:</label>
          <select v-model="itemsPerPage" @change="cambiarItemsPorPagina" class="page-size-select">
            <option :value="20">20</option>
            <option :value="50">50</option>
            <option :value="100">100</option>
          </select>
        </div>
      </div>
    </div>
  </div>

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'consultaLicenciafrm'"
    :moduleName="'ayuda/padron_licencias'"
    @close="closeDocumentation"
  />
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useExcelExport } from '@/composables/useExcelExport'
import { usePdfExport } from '@/composables/usePdfExport'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

// Composables
const { execute, loading } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { exportToExcel } = useExcelExport()
const { exportToPdf } = usePdfExport()
const showDocumentation = ref(false)
const closeDocumentation = () => showDocumentation.value = false

// Estados
const licencias = ref([])
const estadisticas = ref([])
const loadingEstadisticas = ref(true)
const showFilters = ref(false)
const primeraBusqueda = ref(false)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(20)
const totalResultados = ref(0)

// Filtros
const filtros = ref({
  id_licencia: '',
  licencia: '',
  vigente: '',
  fecha_desde: '',
  fecha_hasta: '',
  propietario: '',
  rfc: '',
  id_giro: '',
  actividad: '',
  ubicacion: '',
  colonia: ''
})

// Computed
const totalPages = computed(() => {
  return Math.ceil(totalResultados.value / itemsPerPage.value)
})

// Funciones de formato
const formatNumber = (num) => {
  if (!num) return '0'
  return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',')
}

const formatDate = (date) => {
  if (!date) return 'N/A'
  const d = new Date(date)
  return d.toLocaleDateString('es-MX', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}

const getVigenteIcon = (vigente) => {
  const icons = {
    'V': 'check-circle',
    'C': 'times-circle',
    'A': 'arrow-up',
    'B': 'arrow-down'
  }
  return icons[vigente] || 'circle'
}

const getVigenteTexto = (vigente) => {
  const textos = {
    'V': 'Vigente',
    'C': 'Cancelado',
    'A': 'Alta',
    'B': 'Baja'
  }
  return textos[vigente] || vigente
}

// Funciones principales
const cargarEstadisticas = async () => {
  loadingEstadisticas.value = true
  try {
    const response = await execute(
      'consulta_licencias_estadisticas',
      'padron_licencias',
      [],
      'guadalajara',
      null,
      'publico'
    )

    if (response.success && response.data && response.data.length > 0) {
      estadisticas.value = response.data
    }
  } catch (error) {
  } finally {
    loadingEstadisticas.value = false
  }
}

const buscarLicencias = async () => {
  showLoading('Buscando licencias...', 'Consultando base de datos')
  primeraBusqueda.value = true
  showFilters.value = false

  try {
    // IMPORTANTE: Enviar TODOS los parámetros en orden posicional (13 total)
    const params = [
      // 1. p_id_licencia
      {
        nombre: 'p_id_licencia',
        valor: filtros.value.id_licencia ? parseInt(filtros.value.id_licencia) : null,
        tipo: 'integer'
      },
      // 2. p_licencia
      {
        nombre: 'p_licencia',
        valor: filtros.value.licencia ? parseInt(filtros.value.licencia) : null,
        tipo: 'integer'
      },
      // 3. p_vigente
      {
        nombre: 'p_vigente',
        valor: filtros.value.vigente || null,
        tipo: 'string'
      },
      // 4. p_fecha_desde
      {
        nombre: 'p_fecha_desde',
        valor: filtros.value.fecha_desde || null,
        tipo: 'date'
      },
      // 5. p_fecha_hasta
      {
        nombre: 'p_fecha_hasta',
        valor: filtros.value.fecha_hasta || null,
        tipo: 'date'
      },
      // 6. p_propietario
      {
        nombre: 'p_propietario',
        valor: filtros.value.propietario || null,
        tipo: 'string'
      },
      // 7. p_rfc
      {
        nombre: 'p_rfc',
        valor: filtros.value.rfc || null,
        tipo: 'string'
      },
      // 8. p_id_giro
      {
        nombre: 'p_id_giro',
        valor: filtros.value.id_giro ? parseInt(filtros.value.id_giro) : null,
        tipo: 'integer'
      },
      // 9. p_actividad
      {
        nombre: 'p_actividad',
        valor: filtros.value.actividad || null,
        tipo: 'string'
      },
      // 10. p_ubicacion
      {
        nombre: 'p_ubicacion',
        valor: filtros.value.ubicacion || null,
        tipo: 'string'
      },
      // 11. p_colonia
      {
        nombre: 'p_colonia',
        valor: filtros.value.colonia || null,
        tipo: 'string'
      },
      // 12. p_page
      {
        nombre: 'p_page',
        valor: currentPage.value,
        tipo: 'integer'
      },
      // 13. p_limit
      {
        nombre: 'p_limit',
        valor: itemsPerPage.value,
        tipo: 'integer'
      }
    ]

    const response = await execute(
      'consulta_licencias_list',
      'padron_licencias',
      params,
      'guadalajara',
      null,
      'publico'
    )

    hideLoading()

    if (response.success && response.data) {
      licencias.value = response.data

      if (response.data.length > 0) {
        totalResultados.value = response.data[0].total_registros || 0

        await Swal.fire({
          icon: 'success',
          title: 'Búsqueda completada',
          text: `Se encontraron ${formatNumber(totalResultados.value)} licencias`,
          timer: 2000,
          showConfirmButton: false
        })
      } else {
        totalResultados.value = 0
        await Swal.fire({
          icon: 'info',
          title: 'Sin resultados',
          text: 'No se encontraron licencias con los filtros seleccionados',
          confirmButtonText: 'Entendido'
        })
      }
    } else {
      throw new Error('Error en la respuesta del servidor')
    }
  } catch (error) {
    hideLoading()
    await Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'Ocurrió un error al buscar las licencias. Intente nuevamente.',
      confirmButtonText: 'Entendido'
    })
  }
}

const cambiarPagina = (nuevaPagina) => {
  if (nuevaPagina < 1 || nuevaPagina > totalPages.value) return
  currentPage.value = nuevaPagina
  buscarLicencias()
}

const cambiarItemsPorPagina = () => {
  currentPage.value = 1
  buscarLicencias()
}

const limpiarFiltros = () => {
  filtros.value = {
    id_licencia: '',
    licencia: '',
    vigente: '',
    fecha_desde: '',
    fecha_hasta: '',
    propietario: '',
    rfc: '',
    id_giro: '',
    actividad: '',
    ubicacion: '',
    colonia: ''
  }
  establecerFechasPorDefecto()
}

const establecerFechasPorDefecto = () => {
  const hoy = new Date()
  const seisMesesAtras = new Date()
  seisMesesAtras.setMonth(seisMesesAtras.getMonth() - 6)

  filtros.value.fecha_hasta = hoy.toISOString().split('T')[0]
  filtros.value.fecha_desde = seisMesesAtras.toISOString().split('T')[0]
}

// Definición de columnas para exportación
const columnasExport = [
  { header: 'ID', key: 'id_licencia', type: 'integer', width: 10 },
  { header: 'Licencia', key: 'licencia', type: 'integer', width: 12 },
  { header: 'Vigente', key: 'vigente_texto', width: 12 },
  { header: 'Propietario', key: 'propietario', width: 35 },
  { header: 'RFC', key: 'rfc', width: 15 },
  { header: 'Giro', key: 'descripcion_giro', width: 30 },
  { header: 'Actividad', key: 'actividad', width: 25 },
  { header: 'Ubicación', key: 'ubicacion', width: 35 },
  { header: 'Colonia', key: 'colonia_ubic', width: 20 },
  { header: 'Empleados', key: 'num_empleados', type: 'integer', width: 10 },
  { header: 'Fecha Otorgamiento', key: 'fecha_otorgamiento_fmt', width: 18 }
]

const exportarExcel = async () => {
  if (licencias.value.length === 0) {
    await Swal.fire({
      icon: 'warning',
      title: 'Sin datos',
      text: 'No hay licencias para exportar. Realice una búsqueda primero.',
      confirmButtonText: 'Entendido'
    })
    return
  }

  showLoading('Exportando a Excel...', 'Generando archivo')

  try {
    await new Promise(resolve => setTimeout(resolve, 100))

    // Preparar datos con formato
    const datosExport = licencias.value.map(lic => ({
      ...lic,
      vigente_texto: getVigenteTexto(lic.vigente),
      fecha_otorgamiento_fmt: formatDate(lic.fecha_otorgamiento)
    }))

    const success = exportToExcel(datosExport, columnasExport, 'Consulta_Licencias')

    if (success) {
      await Swal.fire({
        icon: 'success',
        title: 'Excel generado',
        text: `Se exportaron ${licencias.value.length} licencias correctamente`,
        timer: 2000,
        showConfirmButton: false
      })
    }
  } catch (error) {
    await Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'Ocurrió un error al generar el archivo Excel',
      confirmButtonText: 'Entendido'
    })
  } finally {
    hideLoading()
  }
}

const exportarPDF = async () => {
  if (licencias.value.length === 0) {
    await Swal.fire({
      icon: 'warning',
      title: 'Sin datos',
      text: 'No hay licencias para exportar. Realice una búsqueda primero.',
      confirmButtonText: 'Entendido'
    })
    return
  }

  showLoading('Generando PDF...', 'Preparando documento')

  try {
    await new Promise(resolve => setTimeout(resolve, 100))

    // Preparar datos con formato
    const datosExport = licencias.value.map(lic => ({
      ...lic,
      vigente_texto: getVigenteTexto(lic.vigente),
      fecha_otorgamiento_fmt: formatDate(lic.fecha_otorgamiento)
    }))

    const success = exportToPdf(datosExport, columnasExport, {
      title: 'Consulta de Licencias',
      subtitle: `Filtros aplicados - Total: ${formatNumber(totalResultados.value)} registros`,
      orientation: 'landscape'
    })

    if (success) {
      await Swal.fire({
        icon: 'success',
        title: 'PDF generado',
        text: 'El documento se ha enviado a impresión',
        timer: 2000,
        showConfirmButton: false
      })
    }
  } catch (error) {
    await Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'Ocurrió un error al generar el PDF',
      confirmButtonText: 'Entendido'
    })
  } finally {
    hideLoading()
  }
}

const openDocumentation = () => {
  showDocumentation.value = true
}

// Lifecycle
onMounted(async () => {
  establecerFechasPorDefecto()
  await cargarEstadisticas()
})
</script>

<style scoped>
/* Los estilos están en municipal-theme.css */
.consulta-licencias-container {
  padding: 2rem;
}

/* Badges personalizados para vigente */
.badge-vigente {
  display: inline-block;
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
}

.badge-V {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
}

.badge-C {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  color: white;
}

.badge-A {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  color: white;
}

.badge-B {
  background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
  color: white;
}

/* Personalización de stats-grid para 4 columnas */
.stats-grid {
  grid-template-columns: repeat(4, 1fr) !important;
}

@media (max-width: 1200px) {
  .stats-grid {
    grid-template-columns: repeat(2, 1fr) !important;
  }
}

@media (max-width: 768px) {
  .stats-grid {
    grid-template-columns: repeat(1, 1fr) !important;
  }
}
</style>
