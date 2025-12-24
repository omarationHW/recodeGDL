<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header header-relative">
      <div class="module-view-icon">
        <font-awesome-icon icon="table" />
      </div>
      <div class="module-view-info">
        <h1>Propuestas de Tabulador</h1>
        <p>Padrón de Licencias - Consulta de Históricos y Propuestas</p>
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
          >
            <font-awesome-icon icon="search" />
            Buscar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="limpiarFiltros"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Pestañas de históricos -->
    <div class="municipal-card">
      <div class="municipal-tabs">
        <button
          class="municipal-tab"
          :class="{ active: activeTab === 'propuestas' }"
          @click="activeTab = 'propuestas'"
        >
          <font-awesome-icon icon="file-invoice" />
          Propuestas
        </button>
        <button
          class="municipal-tab"
          :class="{ active: activeTab === 'cuenta' }"
          @click="activeTab = 'cuenta'; cargarHistoricoCuenta()"
        >
          <font-awesome-icon icon="receipt" />
          Histórico Cuenta
        </button>
        <button
          class="municipal-tab"
          :class="{ active: activeTab === 'predial' }"
          @click="activeTab = 'predial'; cargarHistoricoPredial()"
        >
          <font-awesome-icon icon="home" />
          Histórico Predial
        </button>
        <button
          class="municipal-tab"
          :class="{ active: activeTab === 'ubicacion' }"
          @click="activeTab = 'ubicacion'; cargarHistoricoUbicacion()"
        >
          <font-awesome-icon icon="map-marker-alt" />
          Ubicación
        </button>
        <button
          class="municipal-tab"
          :class="{ active: activeTab === 'valores' }"
          @click="activeTab = 'valores'; cargarHistoricoValores()"
        >
          <font-awesome-icon icon="dollar-sign" />
          Valores
        </button>
        <button
          class="municipal-tab"
          :class="{ active: activeTab === 'diferencias' }"
          @click="activeTab = 'diferencias'; cargarHistoricoDiferencias()"
        >
          <font-awesome-icon icon="chart-line" />
          Diferencias
        </button>
        <button
          class="municipal-tab"
          :class="{ active: activeTab === 'regimen' }"
          @click="activeTab = 'regimen'; cargarHistoricoRegimen()"
        >
          <font-awesome-icon icon="building" />
          Régimen
        </button>
        <button
          class="municipal-tab"
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
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="file-invoice" />
          Lista de Propuestas
        </h5>
        <div class="header-right">
          <span class="badge-purple" v-if="propuestas.length > 0">
            {{ propuestas.length }} registros
          </span>
        </div>
      </div>
      <div class="municipal-card-body">
        <!-- Empty State - Sin búsqueda -->
        <div v-if="propuestas.length === 0 && !hasSearched" class="empty-state">
          <div class="empty-state-icon">
            <font-awesome-icon icon="file-invoice" size="3x" />
          </div>
          <h4>Propuestas de Tabulador</h4>
          <p>Ingrese los criterios de búsqueda para consultar las propuestas</p>
        </div>

        <!-- Empty State - Sin resultados -->
        <div v-else-if="propuestas.length === 0 && hasSearched" class="empty-state">
          <div class="empty-state-icon">
            <font-awesome-icon icon="inbox" size="3x" />
          </div>
          <h4>Sin resultados</h4>
          <p>No se encontraron propuestas con los criterios especificados</p>
        </div>

        <!-- Tabla de resultados -->
        <div v-else class="table-container">
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
                <tr
                  v-for="propuesta in propuestas"
                  :key="propuesta.id"
                  @click="selectedRow = propuesta"
                  :class="{ 'table-row-selected': selectedRow === propuesta }"
                  class="row-hover"
                >
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
                      @click.stop="verDetallePropuesta(propuesta)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Tab: Histórico de Cuenta -->
    <div v-show="activeTab === 'cuenta'" class="municipal-card">
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="receipt" />
          Histórico de Cuenta
        </h5>
        <div class="header-right">
          <span class="badge-purple" v-if="historicoCuenta.length > 0">
            {{ historicoCuenta.length }} registros
          </span>
        </div>
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
              <tr
                v-for="(registro, index) in historicoCuenta"
                :key="index"
                @click="selectedRow = registro"
                :class="{ 'table-row-selected': selectedRow === registro }"
                class="row-hover"
              >
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
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="home" />
          Histórico Predial
        </h5>
        <div class="header-right">
          <span class="badge-purple" v-if="historicoPredial.length > 0">
            {{ historicoPredial.length }} registros
          </span>
        </div>
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
              <tr
                v-for="(registro, index) in historicoPredial"
                :key="index"
                @click="selectedRow = registro"
                :class="{ 'table-row-selected': selectedRow === registro }"
                class="row-hover"
              >
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
              <tr
                v-for="(valor, index) in historicoValores"
                :key="index"
                @click="selectedRow = valor"
                :class="{ 'table-row-selected': selectedRow === valor }"
                class="row-hover"
              >
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
              <tr
                v-for="(diff, index) in historicoDiferencias"
                :key="index"
                @click="selectedRow = diff"
                :class="{ 'table-row-selected': selectedRow === diff }"
                class="row-hover"
              >
                <td><strong>{{ diff.periodo }}</strong></td>
                <td>{{ diff.diferencia }}</td>
                <td>
                  <span class="badge-purple">{{ diff.tipo }}</span>
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
              <tr
                v-for="(regimen, index) in historicoRegimen"
                :key="index"
                @click="selectedRow = regimen"
                :class="{ 'table-row-selected': selectedRow === regimen }"
                class="row-hover"
              >
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
      :componentName="'Propuestatab'"
      :moduleName="'padron_licencias'"
      :docType="docType"
      :title="'Propuestas de Tabulador'"
      @close="showDocModal = false"
    />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

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
const activeTab = ref('propuestas')
const propuestas = ref([])
const historicoCuenta = ref([])
const historicoPredial = ref([])
const historicoUbicacion = ref([])
const historicoValores = ref([])
const historicoDiferencias = ref([])
const historicoRegimen = ref([])
const condominioInfo = ref(null)
const selectedRow = ref(null)
const hasSearched = ref(false)

// Filtros
const filters = ref({
  cuenta: '',
  claveCatastral: '',
  anio: new Date().getFullYear()
})

// Métodos
const buscarPropuestas = async () => {
  showLoading('Buscando propuestas...', 'Por favor espere')
  hasSearched.value = true
  selectedRow.value = null
  try {
    const response = await execute(
      'sp_propuestatab_list',
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
    hideLoading()
  }
}

const cargarHistoricoCuenta = async () => {
  if (!filters.value.cuenta) {
    showToast('warning', 'Ingrese una cuenta para consultar el histórico')
    return
  }

  showLoading('Cargando histórico de cuenta...', 'Por favor espere')
  selectedRow.value = null
  try {
    const response = await execute(
      'sp_get_cuenta_historico',
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
    hideLoading()
  }
}

const cargarHistoricoPredial = async () => {
  if (!filters.value.cuenta) {
    showToast('warning', 'Ingrese una cuenta para consultar el histórico')
    return
  }

  showLoading('Cargando histórico predial...', 'Por favor espere')
  selectedRow.value = null
  try {
    const response = await execute(
      'sp_get_predial_historico',
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
    hideLoading()
  }
}

const cargarHistoricoUbicacion = async () => {
  if (!filters.value.cuenta) {
    showToast('warning', 'Ingrese una cuenta para consultar el histórico')
    return
  }

  showLoading('Cargando histórico de ubicación...', 'Por favor espere')
  selectedRow.value = null
  try {
    const response = await execute(
      'sp_get_ubicacion_historico',
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
    hideLoading()
  }
}

const cargarHistoricoValores = async () => {
  if (!filters.value.cuenta) {
    showToast('warning', 'Ingrese una cuenta para consultar el histórico')
    return
  }

  showLoading('Cargando histórico de valores...', 'Por favor espere')
  selectedRow.value = null
  try {
    const response = await execute(
      'sp_get_valores_historico',
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
    hideLoading()
  }
}

const cargarHistoricoDiferencias = async () => {
  if (!filters.value.cuenta) {
    showToast('warning', 'Ingrese una cuenta para consultar el histórico')
    return
  }

  showLoading('Cargando histórico de diferencias...', 'Por favor espere')
  selectedRow.value = null
  try {
    const response = await execute(
      'sp_get_diferencias_historico',
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
    hideLoading()
  }
}

const cargarHistoricoRegimen = async () => {
  if (!filters.value.cuenta) {
    showToast('warning', 'Ingrese una cuenta para consultar el histórico')
    return
  }

  showLoading('Cargando histórico de régimen...', 'Por favor espere')
  selectedRow.value = null
  try {
    const response = await execute(
      'sp_get_regimen_propiedad_historico',
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
    hideLoading()
  }
}

const cargarCondominio = async () => {
  if (!filters.value.cuenta) {
    showToast('warning', 'Ingrese una cuenta para consultar')
    return
  }

  showLoading('Cargando información de condominio...', 'Por favor espere')
  selectedRow.value = null
  try {
    const response = await execute(
      'sp_propuestatab_condominio',
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
    hideLoading()
  }
}

const verDetallePropuesta = () => {
  // Implementar modal de detalles si es necesario
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
  hasSearched.value = false
  selectedRow.value = null
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
  } catch {
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

