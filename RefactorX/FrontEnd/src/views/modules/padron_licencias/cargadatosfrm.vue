<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="upload" />
      </div>
      <div class="module-view-info">
        <h1>Carga de Datos Catastrales</h1>
        <p>Padrón de Licencias - Importación y Procesamiento de Información Catastral</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Panel de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="file-import" />
          Búsqueda de Datos Catastrales
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Clave Catastral *</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="cvecatnva"
              placeholder="Ingrese la clave catastral"
              @keyup.enter="consultarDatos"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Subpredio (opcional)</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="subpredio"
              placeholder="Número de subpredio"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="consultarDatos"
            :disabled="!cvecatnva"
          >
            <font-awesome-icon icon="search" />
            Consultar Datos
          </button>
          <button
            class="btn-municipal-secondary"
            @click="limpiarFormulario"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
          <button
            class="btn-municipal-success"
            @click="guardarDatos"
            :disabled="!cvecatnva || !datosGenerales"
          >
            <font-awesome-icon icon="save" />
            Guardar Cambios
          </button>
        </div>
      </div>
    </div>

    <!-- Pestañas de datos -->
    <div class="municipal-card" v-if="datosGenerales">
      <div class="municipal-tabs">
        <button
          class="municipal-tab"
          :class="{ active: activeTab === 'general' }"
          @click="activeTab = 'general'"
        >
          <font-awesome-icon icon="info-circle" />
          Datos Generales
        </button>
        <button
          class="municipal-tab"
          :class="{ active: activeTab === 'avaluos' }"
          @click="activeTab = 'avaluos'; cargarAvaluos()"
        >
          <font-awesome-icon icon="money-bill-wave" />
          Avalúos
        </button>
        <button
          class="municipal-tab"
          :class="{ active: activeTab === 'construcciones' }"
          @click="activeTab = 'construcciones'"
        >
          <font-awesome-icon icon="home" />
          Construcciones
        </button>
        <button
          class="municipal-tab"
          :class="{ active: activeTab === 'area_carto' }"
          @click="activeTab = 'area_carto'; cargarAreaCarto()"
        >
          <font-awesome-icon icon="map" />
          Área Cartográfica
        </button>
      </div>
    </div>

    <!-- Tab: Datos Generales -->
    <div v-show="activeTab === 'general'" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="info-circle" />
          Datos Generales del Predio
        </h5>
      </div>
      <div class="municipal-card-body">
        <div v-if="datosGenerales" class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="map-marked-alt" />
              Ubicación
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Calle:</td>
                <td><strong>{{ datosGenerales.calle || 'N/A' }}</strong></td>
              </tr>
              <tr>
                <td class="label">No. Exterior:</td>
                <td>{{ datosGenerales.noexterior || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Interior:</td>
                <td>{{ datosGenerales.interior || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Colonia:</td>
                <td>{{ datosGenerales.colonia || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Código Postal:</td>
                <td><code>{{ datosGenerales.codpos || 'N/A' }}</code></td>
              </tr>
            </table>
          </div>
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="user" />
              Propietario
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Nombre:</td>
                <td><strong>{{ datosGenerales.propietario || 'N/A' }}</strong></td>
              </tr>
              <tr>
                <td class="label">RFC:</td>
                <td><code>{{ datosGenerales.rfc || 'N/A' }}</code></td>
              </tr>
            </table>
          </div>
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="money-bill-wave" />
              Valores del Avalúo Vigente
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Sup. Terreno:</td>
                <td>{{ datosGenerales.supterr || 0 }} m²</td>
              </tr>
              <tr>
                <td class="label">Sup. Construcción:</td>
                <td>{{ datosGenerales.supconst || 0 }} m²</td>
              </tr>
              <tr>
                <td class="label">Valor Terreno:</td>
                <td><strong>${{ formatCurrency(datosGenerales.valorterr) }}</strong></td>
              </tr>
              <tr>
                <td class="label">Valor Construcción:</td>
                <td><strong>${{ formatCurrency(datosGenerales.valorconst) }}</strong></td>
              </tr>
              <tr>
                <td class="label">Valor Fiscal:</td>
                <td><strong class="text-success">${{ formatCurrency(datosGenerales.valfiscal) }}</strong></td>
              </tr>
              <tr v-if="datosGenerales.observacion">
                <td class="label">Observaciones:</td>
                <td><em>{{ datosGenerales.observacion }}</em></td>
              </tr>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Tab: Avalúos -->
    <div v-show="activeTab === 'avaluos'" class="municipal-card">
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="money-bill-wave" />
          Datos de Avalúos
        </h5>
        <div class="header-right">
          <span class="badge-purple" v-if="avaluos.length > 0">
            {{ avaluos.length }} registros
          </span>
        </div>
      </div>
      <div class="municipal-card-body table-container">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>ID Avalúo</th>
                <th>Cuenta</th>
                <th>Clave Catastral</th>
                <th>Valor Terreno</th>
                <th>Valor Construcción</th>
                <th>Valor Total</th>
                <th>Fecha</th>
                <th>Estado</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="avaluo in avaluos"
                :key="avaluo.id"
                @click="selectedRow = avaluo"
                :class="{ 'table-row-selected': selectedRow === avaluo }"
                class="row-hover"
              >
                <td><strong>{{ avaluo.id }}</strong></td>
                <td>{{ avaluo.cuenta || 'N/A' }}</td>
                <td><code>{{ avaluo.clave_catastral || 'N/A' }}</code></td>
                <td>${{ formatCurrency(avaluo.valor_terreno) }}</td>
                <td>${{ formatCurrency(avaluo.valor_construccion) }}</td>
                <td><strong>${{ formatCurrency(avaluo.valor_total) }}</strong></td>
                <td>{{ formatDate(avaluo.fecha) }}</td>
                <td>
                  <span class="badge" :class="getBadgeClass(avaluo.estado)">
                    {{ avaluo.estado }}
                  </span>
                </td>
              </tr>
              <tr v-if="avaluos.length === 0">
                <td colspan="8" class="text-center text-muted">
                  <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                  <p>No hay datos de avalúos disponibles</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Tab: Construcciones -->
    <div v-show="activeTab === 'construcciones'" class="municipal-card">
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="home" />
          Datos de Construcciones
        </h5>
        <div class="header-right">
          <span class="badge-purple" v-if="construcciones.length > 0">
            {{ construcciones.length }} registros
          </span>
        </div>
      </div>
      <div class="municipal-card-body table-container">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>ID</th>
                <th>Cuenta</th>
                <th>Tipo Construcción</th>
                <th>Superficie</th>
                <th>Año Construcción</th>
                <th>Uso</th>
                <th>Calidad</th>
                <th>Estado</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="construccion in construcciones"
                :key="construccion.id"
                @click="selectedRow = construccion"
                :class="{ 'table-row-selected': selectedRow === construccion }"
                class="row-hover"
              >
                <td><strong>{{ construccion.id }}</strong></td>
                <td>{{ construccion.cuenta || 'N/A' }}</td>
                <td>{{ construccion.tipo_construccion || 'N/A' }}</td>
                <td>{{ construccion.superficie }} m²</td>
                <td>{{ construccion.anio_construccion || 'N/A' }}</td>
                <td>{{ construccion.uso || 'N/A' }}</td>
                <td>
                  <span class="badge-secondary">{{ construccion.calidad || 'N/A' }}</span>
                </td>
                <td>
                  <span class="badge" :class="getBadgeClass(construccion.estado)">
                    {{ construccion.estado }}
                  </span>
                </td>
              </tr>
              <tr v-if="construcciones.length === 0">
                <td colspan="8" class="text-center text-muted">
                  <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                  <p>No hay datos de construcciones disponibles</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Tab: Área Cartográfica -->
    <div v-show="activeTab === 'area_carto'" class="municipal-card">
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="map" />
          Área Cartográfica Total
        </h5>
        <div class="header-right">
          <span class="badge-purple" v-if="areaCarto">
            {{ areaCarto }} m²
          </span>
        </div>
      </div>
      <div class="municipal-card-body">
        <div v-if="areaCarto !== null" class="text-center area-carto-display">
          <font-awesome-icon icon="map" size="3x" class="area-carto-icon" />
          <h3 class="area-carto-title">Superficie Total de Construcción</h3>
          <p class="area-carto-value">
            {{ areaCarto }} m²
          </p>
          <p class="area-carto-description">
            Superficie total de construcción cartográfica vigente para la clave catastral {{ cvecatnva }}
          </p>
        </div>
        <div v-else class="text-center text-muted empty-area-carto">
          <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
          <p>No hay datos de área cartográfica disponibles</p>
        </div>
      </div>
    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <div class="toast-content">
        <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
        <span class="toast-message">{{ toast.message }}</span>
      </div>
      <span v-if="toast.duration" class="toast-duration">{{ toast.duration }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'cargadatosfrm'"
      :moduleName="'padron_licencias'"
      :docType="docType"
      :title="'Carga de Datos Catastrales'"
      @close="showDocModal = false"
    />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

// Documentación y Ayuda
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

const { execute } = useApi()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const activeTab = ref('general')
const cvecatnva = ref('')
const subpredio = ref(null)
const datosGenerales = ref(null)
const avaluos = ref([])
const construcciones = ref([])
const areaCarto = ref(null)
const cveavaluo = ref(null)
const selectedRow = ref(null)
const hasSearched = ref(false)

// Métodos
const consultarDatos = async () => {
  if (!cvecatnva.value) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'Por favor ingrese una clave catastral',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  showLoading('Consultando datos catastrales...', 'Procesando información catastral')
  hasSearched.value = true
  selectedRow.value = null

  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_get_cargadatos',
      'padron_licencias',
      [
        { nombre: 'p_cvecatnva', valor: cvecatnva.value, tipo: 'string' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    if (response && response.result && response.result.length > 0) {
      datosGenerales.value = response.result[0]
      cveavaluo.value = datosGenerales.value.cveavaluo
      activeTab.value = 'general'
      toast.value.duration = durationText
      showToast('success', 'Datos consultados correctamente')
    } else {
      datosGenerales.value = null
      await Swal.fire({
        icon: 'info',
        title: 'Sin datos',
        text: 'No se encontraron datos para la clave catastral especificada',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    datosGenerales.value = null
  } finally {
    hideLoading()
  }
}

const limpiarFormulario = () => {
  cvecatnva.value = ''
  subpredio.value = null
  datosGenerales.value = null
  avaluos.value = []
  construcciones.value = []
  areaCarto.value = null
  cveavaluo.value = null
  activeTab.value = 'general'
  hasSearched.value = false
  selectedRow.value = null
  showToast('info', 'Formulario limpiado')
}

const guardarDatos = async () => {
  if (!cvecatnva.value || !datosGenerales.value) {
    await Swal.fire({
      icon: 'warning',
      title: 'Sin datos',
      text: 'Primero debe consultar los datos de una clave catastral',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const result = await Swal.fire({
    title: 'Guardar cambios',
    text: '¿Desea guardar los cambios realizados?',
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#28a745',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, guardar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  const usuario = localStorage.getItem('usuario') || 'sistema'

  showLoading('Guardando cambios...', 'Procesando información')
  selectedRow.value = null

  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_save_cargadatos',
      'padron_licencias',
      [
        { nombre: 'p_cvecatnva', valor: cvecatnva.value, tipo: 'string' },
        { nombre: 'p_data', valor: JSON.stringify(datosGenerales.value), tipo: 'json' },
        { nombre: 'p_user', valor: usuario, tipo: 'string' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    if (response && response.result) {
      await Swal.fire({
        icon: 'success',
        title: 'Datos guardados',
        text: 'Los cambios se han guardado correctamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      toast.value.duration = durationText
      showToast('success', 'Cambios guardados correctamente')

      // Recargar datos
      await consultarDatos()
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const cargarAvaluos = async () => {
  if (!cvecatnva.value) {
    showToast('warning', 'Primero debe consultar una clave catastral')
    return
  }

  showLoading('Cargando avalúos...', 'Obteniendo datos de avalúos')
  selectedRow.value = null

  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_get_avaluos',
      'padron_licencias',
      [
        { nombre: 'p_cvecatnva', valor: cvecatnva.value, tipo: 'string' },
        { nombre: 'p_subpredio', valor: subpredio.value, tipo: 'integer' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    if (response && response.result) {
      avaluos.value = response.result
      toast.value.duration = durationText
      showToast('success', `Se cargaron ${avaluos.value.length} avalúos`)
    }
  } catch (error) {
    handleApiError(error)
    avaluos.value = []
  } finally {
    hideLoading()
  }
}

const cargarConstrucciones = async () => {
  if (!cveavaluo.value) {
    await Swal.fire({
      icon: 'warning',
      title: 'Sin avalúo',
      text: 'No hay un avalúo vigente para cargar las construcciones. Primero consulte los datos generales.',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  showLoading('Cargando construcciones...', 'Obteniendo datos de construcciones')
  selectedRow.value = null

  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_get_construcciones',
      'padron_licencias',
      [
        { nombre: 'p_cveavaluo', valor: cveavaluo.value, tipo: 'integer' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    if (response && response.result) {
      construcciones.value = response.result
      toast.value.duration = durationText
      showToast('success', `Se cargaron ${construcciones.value.length} construcciones`)
    }
  } catch (error) {
    handleApiError(error)
    construcciones.value = []
  } finally {
    hideLoading()
  }
}

const cargarAreaCarto = async () => {
  if (!cvecatnva.value) {
    showToast('warning', 'Primero debe consultar una clave catastral')
    return
  }

  showLoading('Cargando área cartográfica...', 'Obteniendo datos cartográficos')
  selectedRow.value = null

  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_get_area_carto',
      'padron_licencias',
      [
        { nombre: 'p_cvecatnva', valor: cvecatnva.value, tipo: 'string' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    if (response && response.result && response.result.length > 0) {
      areaCarto.value = response.result[0].supconst || 0
      toast.value.duration = durationText
      showToast('success', 'Área cartográfica cargada')
    } else {
      areaCarto.value = null
      showToast('info', 'No hay área cartográfica disponible')
    }
  } catch (error) {
    handleApiError(error)
    areaCarto.value = null
  } finally {
    hideLoading()
  }
}

// Utilidades
const getBadgeClass = (estado) => {
  const classes = {
    completado: 'badge-success',
    procesando: 'badge-purple',
    pendiente: 'badge-warning',
    error: 'badge-danger'
  }
  return classes[estado?.toLowerCase()] || 'badge-secondary'
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    })
  } catch (error) {
    return 'Fecha inválida'
  }
}

const formatDateTime = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
  } catch (error) {
    return 'Fecha inválida'
  }
}

const formatCurrency = (value) => {
  if (!value && value !== 0) return '0.00'
  return parseFloat(value).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
}

// Lifecycle
onMounted(() => {
  // Inicialización
})
</script>
