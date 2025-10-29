<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="table" />
      </div>
      <div class="module-view-info">
        <h1>Propuestas de Tabulador</h1>
        <p>Padrón de Licencias - Consulta de Históricos y Propuestas</p></div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Cuenta Predial</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.cuenta"
              placeholder="Número de cuenta"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Clave Catastral</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.claveCatastral"
              placeholder="Clave catastral"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Año</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="filters.anio"
              :placeholder="new Date().getFullYear()"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="buscarPropuestas"
            :disabled="loading"
          >
            <font-awesome-icon icon="search" />
            Buscar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="limpiarFiltros"
            :disabled="loading"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Pestañas de históricos -->
    <div class="municipal-card">
      <div class="tabs-container">
        <button
          class="tab-button"
          :class="{ active: activeTab === 'propuestas' }"
          @click="activeTab = 'propuestas'"
        >
          <font-awesome-icon icon="file-invoice" />
          Propuestas
        </button>
        <button
          class="tab-button"
          :class="{ active: activeTab === 'cuenta' }"
          @click="activeTab = 'cuenta'; cargarHistoricoCuenta()"
        >
          <font-awesome-icon icon="receipt" />
          Histórico Cuenta
        </button>
        <button
          class="tab-button"
          :class="{ active: activeTab === 'predial' }"
          @click="activeTab = 'predial'; cargarHistoricoPredial()"
        >
          <font-awesome-icon icon="home" />
          Histórico Predial
        </button>
        <button
          class="tab-button"
          :class="{ active: activeTab === 'ubicacion' }"
          @click="activeTab = 'ubicacion'; cargarHistoricoUbicacion()"
        >
          <font-awesome-icon icon="map-marker-alt" />
          Ubicación
        </button>
        <button
          class="tab-button"
          :class="{ active: activeTab === 'valores' }"
          @click="activeTab = 'valores'; cargarHistoricoValores()"
        >
          <font-awesome-icon icon="dollar-sign" />
          Valores
        </button>
        <button
          class="tab-button"
          :class="{ active: activeTab === 'diferencias' }"
          @click="activeTab = 'diferencias'; cargarHistoricoDiferencias()"
        >
          <font-awesome-icon icon="chart-line" />
          Diferencias
        </button>
        <button
          class="tab-button"
          :class="{ active: activeTab === 'regimen' }"
          @click="activeTab = 'regimen'; cargarHistoricoRegimen()"
        >
          <font-awesome-icon icon="building" />
          Régimen
        </button>
        <button
          class="tab-button"
          :class="{ active: activeTab === 'condominio' }"
          @click="activeTab = 'condominio'; cargarCondominio()"
        >
          <font-awesome-icon icon="city" />
          Condominio
        </button>
      </div>
    </div>

    <!-- Tab: Propuestas -->
    <div v-show="activeTab === 'propuestas'" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="file-invoice" />
          Lista de Propuestas
          <span class="badge-info" v-if="propuestas.length > 0">{{ propuestas.length }} registros</span>
        </h5>
      </div>
      <div class="municipal-card-body table-container" v-if="!loading">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>ID</th>
                <th>Cuenta</th>
                <th>Clave Catastral</th>
                <th>Propietario</th>
                <th>Ubicación</th>
                <th>Tipo</th>
                <th>Fecha</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="propuesta in propuestas" :key="propuesta.id" class="row-hover">
                <td><strong>{{ propuesta.id }}</strong></td>
                <td>{{ propuesta.cuenta || 'N/A' }}</td>
                <td><code>{{ propuesta.clave_catastral || 'N/A' }}</code></td>
                <td>{{ propuesta.propietario || 'N/A' }}</td>
                <td>{{ propuesta.ubicacion || 'N/A' }}</td>
                <td>
                  <span class="badge-secondary">{{ propuesta.tipo || 'N/A' }}</span>
                </td>
                <td>
                  <small class="text-muted">{{ formatDate(propuesta.fecha) }}</small>
                </td>
                <td>
                  <button
                    class="btn-municipal-info btn-sm"
                    @click="verDetallePropuesta(propuesta)"
                    title="Ver detalles"
                  >
                    <font-awesome-icon icon="eye" />
                  </button>
                </td>
              </tr>
              <tr v-if="propuestas.length === 0">
                <td colspan="8" class="text-center text-muted">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>No se encontraron propuestas</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Tab: Histórico de Cuenta -->
    <div v-show="activeTab === 'cuenta'" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="receipt" />
          Histórico de Cuenta
          <span class="badge-info" v-if="historicoCuenta.length > 0">{{ historicoCuenta.length }} registros</span>
        </h5>
      </div>
      <div class="municipal-card-body table-container">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Cuenta</th>
                <th>Año</th>
                <th>Período</th>
                <th>Importe</th>
                <th>Recargos</th>
                <th>Total</th>
                <th>Estado</th>
                <th>Fecha Pago</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(registro, index) in historicoCuenta" :key="index" class="row-hover">
                <td><strong>{{ registro.cuenta }}</strong></td>
                <td>{{ registro.anio }}</td>
                <td>{{ registro.periodo }}</td>
                <td>${{ formatCurrency(registro.importe) }}</td>
                <td>${{ formatCurrency(registro.recargos) }}</td>
                <td><strong>${{ formatCurrency(registro.total) }}</strong></td>
                <td>
                  <span class="badge" :class="registro.pagado ? 'badge-success' : 'badge-danger'">
                    {{ registro.pagado ? 'Pagado' : 'Pendiente' }}
                  </span>
                </td>
                <td>{{ formatDate(registro.fecha_pago) }}</td>
              </tr>
              <tr v-if="historicoCuenta.length === 0">
                <td colspan="8" class="text-center text-muted">
                  <p>No hay datos disponibles</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Tab: Histórico Predial -->
    <div v-show="activeTab === 'predial'" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="home" />
          Histórico Predial
          <span class="badge-info" v-if="historicoPredial.length > 0">{{ historicoPredial.length }} registros</span>
        </h5>
      </div>
      <div class="municipal-card-body table-container">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Cuenta</th>
                <th>Año</th>
                <th>Superficie Terreno</th>
                <th>Superficie Construcción</th>
                <th>Valor Terreno</th>
                <th>Valor Construcción</th>
                <th>Valor Catastral</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(registro, index) in historicoPredial" :key="index" class="row-hover">
                <td><strong>{{ registro.cuenta }}</strong></td>
                <td>{{ registro.anio }}</td>
                <td>{{ registro.sup_terreno }} m²</td>
                <td>{{ registro.sup_construccion }} m²</td>
                <td>${{ formatCurrency(registro.valor_terreno) }}</td>
                <td>${{ formatCurrency(registro.valor_construccion) }}</td>
                <td><strong>${{ formatCurrency(registro.valor_catastral) }}</strong></td>
              </tr>
              <tr v-if="historicoPredial.length === 0">
                <td colspan="7" class="text-center text-muted">
                  <p>No hay datos disponibles</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Tab: Ubicación -->
    <div v-show="activeTab === 'ubicacion'" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="map-marker-alt" />
          Histórico de Ubicación
        </h5>
      </div>
      <div class="municipal-card-body">
        <div v-if="historicoUbicacion.length > 0">
          <div v-for="(ubicacion, index) in historicoUbicacion" :key="index" class="info-card">
            <h6>Registro {{ index + 1 }}</h6>
            <div class="info-grid">
              <div class="info-item">
                <strong>Calle:</strong> {{ ubicacion.calle || 'N/A' }}
              </div>
              <div class="info-item">
                <strong>Número:</strong> {{ ubicacion.numero || 'N/A' }}
              </div>
              <div class="info-item">
                <strong>Colonia:</strong> {{ ubicacion.colonia || 'N/A' }}
              </div>
              <div class="info-item">
                <strong>C.P.:</strong> {{ ubicacion.cp || 'N/A' }}
              </div>
              <div class="info-item">
                <strong>Municipio:</strong> {{ ubicacion.municipio || 'N/A' }}
              </div>
              <div class="info-item">
                <strong>Fecha:</strong> {{ formatDate(ubicacion.fecha) }}
              </div>
            </div>
          </div>
        </div>
        <div v-else class="text-center text-muted">
          <p>No hay datos disponibles</p>
        </div>
      </div>
    </div>

    <!-- Tab: Valores -->
    <div v-show="activeTab === 'valores'" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="dollar-sign" />
          Histórico de Valores
        </h5>
      </div>
      <div class="municipal-card-body table-container">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Año</th>
                <th>Valor Base</th>
                <th>Incremento</th>
                <th>Valor Final</th>
                <th>Observaciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(valor, index) in historicoValores" :key="index" class="row-hover">
                <td><strong>{{ valor.anio }}</strong></td>
                <td>${{ formatCurrency(valor.valor_base) }}</td>
                <td>{{ valor.incremento }}%</td>
                <td><strong>${{ formatCurrency(valor.valor_final) }}</strong></td>
                <td>{{ valor.observaciones || '-' }}</td>
              </tr>
              <tr v-if="historicoValores.length === 0">
                <td colspan="5" class="text-center text-muted">
                  <p>No hay datos disponibles</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Tab: Diferencias -->
    <div v-show="activeTab === 'diferencias'" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="chart-line" />
          Histórico de Diferencias
        </h5>
      </div>
      <div class="municipal-card-body table-container">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Período</th>
                <th>Diferencia</th>
                <th>Tipo</th>
                <th>Monto</th>
                <th>Fecha Registro</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(diff, index) in historicoDiferencias" :key="index" class="row-hover">
                <td><strong>{{ diff.periodo }}</strong></td>
                <td>{{ diff.diferencia }}</td>
                <td>
                  <span class="badge-info">{{ diff.tipo }}</span>
                </td>
                <td>${{ formatCurrency(diff.monto) }}</td>
                <td>{{ formatDate(diff.fecha_registro) }}</td>
              </tr>
              <tr v-if="historicoDiferencias.length === 0">
                <td colspan="5" class="text-center text-muted">
                  <p>No hay datos disponibles</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Tab: Régimen de Propiedad -->
    <div v-show="activeTab === 'regimen'" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="building" />
          Histórico de Régimen de Propiedad
        </h5>
      </div>
      <div class="municipal-card-body table-container">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Régimen</th>
                <th>Tipo Propiedad</th>
                <th>Propietario</th>
                <th>Fecha Registro</th>
                <th>Vigente</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(regimen, index) in historicoRegimen" :key="index" class="row-hover">
                <td><strong>{{ regimen.regimen }}</strong></td>
                <td>{{ regimen.tipo_propiedad }}</td>
                <td>{{ regimen.propietario }}</td>
                <td>{{ formatDate(regimen.fecha_registro) }}</td>
                <td>
                  <span class="badge" :class="regimen.vigente ? 'badge-success' : 'badge-secondary'">
                    {{ regimen.vigente ? 'Vigente' : 'No Vigente' }}
                  </span>
                </td>
              </tr>
              <tr v-if="historicoRegimen.length === 0">
                <td colspan="5" class="text-center text-muted">
                  <p>No hay datos disponibles</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Tab: Condominio -->
    <div v-show="activeTab === 'condominio'" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="city" />
          Información de Condominio
        </h5>
      </div>
      <div class="municipal-card-body">
        <div v-if="condominioInfo" class="info-card">
          <div class="info-grid">
            <div class="info-item">
              <strong>Nombre Condominio:</strong> {{ condominioInfo.nombre || 'N/A' }}
            </div>
            <div class="info-item">
              <strong>Total Unidades:</strong> {{ condominioInfo.total_unidades || 'N/A' }}
            </div>
            <div class="info-item">
              <strong>Régimen:</strong> {{ condominioInfo.regimen || 'N/A' }}
            </div>
            <div class="info-item">
              <strong>Fecha Constitución:</strong> {{ formatDate(condominioInfo.fecha_constitucion) }}
            </div>
          </div>
        </div>
        <div v-else class="text-center text-muted">
          <p>No hay información de condominio</p>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Cargando datos...</p>
      </div>
    </div>

    </div>
    <!-- /module-view-content -->

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
  <!-- /module-view -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'Propuestatab'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const {
  loading,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const activeTab = ref('propuestas')
const propuestas = ref([])
const historicoCuenta = ref([])
const historicoPredial = ref([])
const historicoUbicacion = ref([])
const historicoValores = ref([])
const historicoDiferencias = ref([])
const historicoRegimen = ref([])
const condominioInfo = ref(null)

// Filtros
const filters = ref({
  cuenta: '',
  claveCatastral: '',
  anio: new Date().getFullYear()
})

// Métodos
const buscarPropuestas = async () => {
  setLoading(true)
  try {
    const response = await execute(
      'PROPUESTATAB_LIST',
      'padron_licencias',
      [
        { nombre: 'p_cuenta', valor: filters.value.cuenta || null },
        { nombre: 'p_clave_catastral', valor: filters.value.claveCatastral || null },
        { nombre: 'p_anio', valor: filters.value.anio }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      propuestas.value = response.result
      showToast('success', 'Propuestas cargadas correctamente')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const cargarHistoricoCuenta = async () => {
  if (!filters.value.cuenta) {
    showToast('warning', 'Ingrese una cuenta para consultar el histórico')
    return
  }

  setLoading(true)
  try {
    const response = await execute(
      'SP_GET_CUENTA_HISTORICO',
      'padron_licencias',
      [
        { nombre: 'p_cuenta', valor: filters.value.cuenta }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      historicoCuenta.value = response.result
      showToast('success', 'Histórico de cuenta cargado')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const cargarHistoricoPredial = async () => {
  if (!filters.value.cuenta) {
    showToast('warning', 'Ingrese una cuenta para consultar el histórico')
    return
  }

  setLoading(true)
  try {
    const response = await execute(
      'SP_GET_PREDIAL_HISTORICO',
      'padron_licencias',
      [
        { nombre: 'p_cuenta', valor: filters.value.cuenta }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      historicoPredial.value = response.result
      showToast('success', 'Histórico predial cargado')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const cargarHistoricoUbicacion = async () => {
  if (!filters.value.cuenta) {
    showToast('warning', 'Ingrese una cuenta para consultar el histórico')
    return
  }

  setLoading(true)
  try {
    const response = await execute(
      'SP_GET_UBICACION_HISTORICO',
      'padron_licencias',
      [
        { nombre: 'p_cuenta', valor: filters.value.cuenta }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      historicoUbicacion.value = response.result
      showToast('success', 'Histórico de ubicación cargado')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const cargarHistoricoValores = async () => {
  if (!filters.value.cuenta) {
    showToast('warning', 'Ingrese una cuenta para consultar el histórico')
    return
  }

  setLoading(true)
  try {
    const response = await execute(
      'SP_GET_VALORES_HISTORICO',
      'padron_licencias',
      [
        { nombre: 'p_cuenta', valor: filters.value.cuenta }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      historicoValores.value = response.result
      showToast('success', 'Histórico de valores cargado')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const cargarHistoricoDiferencias = async () => {
  if (!filters.value.cuenta) {
    showToast('warning', 'Ingrese una cuenta para consultar el histórico')
    return
  }

  setLoading(true)
  try {
    const response = await execute(
      'SP_GET_DIFERENCIAS_HISTORICO',
      'padron_licencias',
      [
        { nombre: 'p_cuenta', valor: filters.value.cuenta }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      historicoDiferencias.value = response.result
      showToast('success', 'Histórico de diferencias cargado')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const cargarHistoricoRegimen = async () => {
  if (!filters.value.cuenta) {
    showToast('warning', 'Ingrese una cuenta para consultar el histórico')
    return
  }

  setLoading(true)
  try {
    const response = await execute(
      'SP_GET_REGIMEN_PROPIEDAD_HISTORICO',
      'padron_licencias',
      [
        { nombre: 'p_cuenta', valor: filters.value.cuenta }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      historicoRegimen.value = response.result
      showToast('success', 'Histórico de régimen cargado')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const cargarCondominio = async () => {
  if (!filters.value.cuenta) {
    showToast('warning', 'Ingrese una cuenta para consultar')
    return
  }

  setLoading(true)
  try {
    const response = await execute(
      'PROPUESTATAB_CONDOMINIO',
      'padron_licencias',
      [
        { nombre: 'p_cuenta', valor: filters.value.cuenta }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]) {
      condominioInfo.value = response.result[0]
      showToast('success', 'Información de condominio cargada')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const verDetallePropuesta = (propuesta) => {
  // Implementar modal de detalles si es necesario
  console.log('Ver detalle:', propuesta)
}

const limpiarFiltros = () => {
  filters.value = {
    cuenta: '',
    claveCatastral: '',
    anio: new Date().getFullYear()
  }
  propuestas.value = []
  historicoCuenta.value = []
  historicoPredial.value = []
  historicoUbicacion.value = []
  historicoValores.value = []
  historicoDiferencias.value = []
  historicoRegimen.value = []
  condominioInfo.value = null
}

// Utilidades
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

const formatCurrency = (value) => {
  if (!value && value !== 0) return '0.00'
  return parseFloat(value).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
}

// Lifecycle
onMounted(() => {
  // Inicialización
})
</script>

<style scoped>
.tabs-container {
  display: flex;
  gap: 0;
  border-bottom: 2px solid #ddd;
  padding: 0;
  flex-wrap: wrap;
}

.tab-button {
  padding: 12px 16px;
  background: transparent;
  border: none;
  border-bottom: 3px solid transparent;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s ease;
  color: #666;
  font-size: 14px;
}

.tab-button:hover {
  background: #f8f9fa;
  color: #ea8215;
}

.tab-button.active {
  color: #ea8215;
  border-bottom-color: #ea8215;
  background: #fff;
}

.info-card {
  background: #f8f9fa;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  padding: 20px;
  margin-bottom: 15px;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 15px;
}

.info-item {
  padding: 10px;
}

.info-item strong {
  display: block;
  margin-bottom: 5px;
  color: #495057;
}

.text-center {
  text-align: center;
}

.text-muted {
  color: #6c757d;
}

.empty-icon {
  margin-bottom: 10px;
  opacity: 0.5;
}
</style>
