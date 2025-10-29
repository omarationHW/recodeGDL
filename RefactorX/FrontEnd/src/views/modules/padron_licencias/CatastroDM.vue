<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="building" />
      </div>
      <div class="module-view-info">
        <h1>Catastro para Desarrollo Municipal</h1>
        <p>Padrón de Licencias - Sistema de Autorizaciones y Dictámenes</p></div>
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

    <!-- Pestañas de navegación -->
    <div class="municipal-card">
      <div class="tabs-container">
        <button
          class="tab-button"
          :class="{ active: activeTab === 'autorizaciones' }"
          @click="activeTab = 'autorizaciones'"
        >
          <font-awesome-icon icon="check-circle" />
          Autorizaciones
        </button>
        <button
          class="tab-button"
          :class="{ active: activeTab === 'fechas' }"
          @click="activeTab = 'fechas'"
        >
          <font-awesome-icon icon="calendar-alt" />
          Cálculo de Fechas
        </button>
        <button
          class="tab-button"
          :class="{ active: activeTab === 'dictamenes' }"
          @click="activeTab = 'dictamenes'"
        >
          <font-awesome-icon icon="file-alt" />
          Dictámenes
        </button>
        <button
          class="tab-button"
          :class="{ active: activeTab === 'derechos' }"
          @click="activeTab = 'derechos'"
        >
          <font-awesome-icon icon="dollar-sign" />
          Derechos
        </button>
      </div>
    </div>

    <!-- Tab: Autorizaciones -->
    <div v-show="activeTab === 'autorizaciones'" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="check-circle" />
          Autorizar Licencias y Anuncios
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Tipo de Autorización</label>
            <select class="municipal-form-control" v-model="autorizacionForm.tipo">
              <option value="licencia">Licencia</option>
              <option value="anuncio">Anuncio</option>
            </select>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Número de Expediente</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="autorizacionForm.expediente"
              placeholder="Número de expediente"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Folio</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="autorizacionForm.folio"
              placeholder="Folio"
            >
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Fecha de Autorización</label>
            <input
              type="date"
              class="municipal-form-control"
              v-model="autorizacionForm.fecha"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Observaciones</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="autorizacionForm.observaciones"
              placeholder="Observaciones"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="autorizarDocumento"
            :disabled="loading"
          >
            <font-awesome-icon icon="check" />
            {{ autorizacionForm.tipo === 'licencia' ? 'Autorizar Licencia' : 'Autorizar Anuncio' }}
          </button>
          <button
            class="btn-municipal-secondary"
            @click="limpiarAutorizacion"
            :disabled="loading"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
        </div>

        <!-- Resultados de autorización -->
        <div v-if="autorizacionResult" class="result-panel">
          <div class="alert alert-success">
            <font-awesome-icon icon="check-circle" />
            <strong>Autorización Exitosa</strong>
            <p>{{ autorizacionResult.mensaje }}</p>
            <p v-if="autorizacionResult.folio">Folio: {{ autorizacionResult.folio }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Tab: Cálculo de Fechas -->
    <div v-show="activeTab === 'fechas'" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="calendar-alt" />
          Cálculo de Fechas
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Tipo de Cálculo</label>
            <select class="municipal-form-control" v-model="fechasForm.tipoCalculo">
              <option value="limite_pago">Fecha Límite de Pago</option>
              <option value="resolucion">Fecha de Resolución</option>
              <option value="visita">Fecha de Visita</option>
            </select>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Fecha Inicial</label>
            <input
              type="date"
              class="municipal-form-control"
              v-model="fechasForm.fechaInicial"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Días Hábiles</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="fechasForm.diasHabiles"
              placeholder="Número de días hábiles"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="calcularFecha"
            :disabled="loading"
          >
            <font-awesome-icon icon="calculator" />
            Calcular Fecha
          </button>
          <button
            class="btn-municipal-secondary"
            @click="verificarInhabil"
            :disabled="loading"
          >
            <font-awesome-icon icon="calendar-check" />
            Verificar Día Inhábil
          </button>
        </div>

        <!-- Resultado de cálculo -->
        <div v-if="fechasResult" class="result-panel">
          <div class="alert alert-info">
            <font-awesome-icon icon="calendar-check" />
            <strong>Resultado del Cálculo</strong>
            <p><strong>Fecha Calculada:</strong> {{ formatDate(fechasResult.fechaCalculada) }}</p>
            <p v-if="fechasResult.diasTranscurridos">
              <strong>Días Transcurridos:</strong> {{ fechasResult.diasTranscurridos }}
            </p>
            <p v-if="fechasResult.esInhabil !== undefined">
              <strong>Es Día Inhábil:</strong>
              <span :class="fechasResult.esInhabil ? 'text-danger' : 'text-success'">
                {{ fechasResult.esInhabil ? 'Sí' : 'No' }}
              </span>
            </p>
          </div>
        </div>
      </div>
    </div>

    <!-- Tab: Dictámenes de Microgeneradores -->
    <div v-show="activeTab === 'dictamenes'" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="file-alt" />
          Dictámenes de Microgeneradores
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Número de Empresa</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="dictamenForm.empresa"
              placeholder="ID de empresa"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Folio del Dictamen</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="dictamenForm.folio"
              placeholder="Folio"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Tipo de Generador</label>
            <select class="municipal-form-control" v-model="dictamenForm.tipoGenerador">
              <option value="solar">Solar</option>
              <option value="eolico">Eólico</option>
              <option value="hidraulico">Hidráulico</option>
              <option value="biogas">Biogás</option>
            </select>
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Capacidad (kW)</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="dictamenForm.capacidad"
              placeholder="Capacidad en kW"
              step="0.01"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Fecha de Solicitud</label>
            <input
              type="date"
              class="municipal-form-control"
              v-model="dictamenForm.fechaSolicitud"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="generarDictamen"
            :disabled="loading"
          >
            <font-awesome-icon icon="file-contract" />
            Generar Dictamen
          </button>
          <button
            class="btn-municipal-info"
            @click="imprimirDictamen"
            :disabled="loading || !dictamenGenerado"
          >
            <font-awesome-icon icon="print" />
            Imprimir Dictamen
          </button>
          <button
            class="btn-municipal-secondary"
            @click="limpiarDictamen"
            :disabled="loading"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
        </div>

        <!-- Resultado de dictamen -->
        <div v-if="dictamenResult" class="result-panel">
          <div class="alert alert-success">
            <font-awesome-icon icon="file-check" />
            <strong>Dictamen Generado</strong>
            <p><strong>Folio:</strong> {{ dictamenResult.folio }}</p>
            <p><strong>Fecha de Emisión:</strong> {{ formatDate(dictamenResult.fechaEmision) }}</p>
            <p><strong>Estado:</strong> {{ dictamenResult.estado }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Tab: Derechos -->
    <div v-show="activeTab === 'derechos'" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="dollar-sign" />
          Consultar Derechos
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Número de Empresa</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="derechosForm.empresa"
              placeholder="ID de empresa"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Tipo de Licencia</label>
            <select class="municipal-form-control" v-model="derechosForm.tipoLicencia">
              <option value="nueva">Nueva</option>
              <option value="renovacion">Renovación</option>
              <option value="ampliacion">Ampliación</option>
            </select>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Año Fiscal</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="derechosForm.anioFiscal"
              :placeholder="new Date().getFullYear()"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="consultarDerechos"
            :disabled="loading"
          >
            <font-awesome-icon icon="search" />
            Consultar Derechos
          </button>
          <button
            class="btn-municipal-secondary"
            @click="actualizarConsulta"
            :disabled="loading"
          >
            <font-awesome-icon icon="sync-alt" />
            Actualizar
          </button>
        </div>

        <!-- Tabla de derechos -->
        <div v-if="derechosList.length > 0" class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Concepto</th>
                <th>Base</th>
                <th>Tasa</th>
                <th>Importe</th>
                <th>Recargos</th>
                <th>Total</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(derecho, index) in derechosList" :key="index" class="row-hover">
                <td>{{ derecho.concepto }}</td>
                <td>${{ formatCurrency(derecho.base) }}</td>
                <td>{{ derecho.tasa }}%</td>
                <td>${{ formatCurrency(derecho.importe) }}</td>
                <td>${{ formatCurrency(derecho.recargos) }}</td>
                <td><strong>${{ formatCurrency(derecho.total) }}</strong></td>
              </tr>
            </tbody>
            <tfoot>
              <tr class="table-footer">
                <td colspan="5" class="text-right"><strong>Total General:</strong></td>
                <td><strong>${{ formatCurrency(totalDerechos) }}</strong></td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Procesando...</p>
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
      :componentName="'CatastroDM'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

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
const activeTab = ref('autorizaciones')
const autorizacionResult = ref(null)
const fechasResult = ref(null)
const dictamenResult = ref(null)
const dictamenGenerado = ref(false)
const derechosList = ref([])

// Formularios
const autorizacionForm = ref({
  tipo: 'licencia',
  expediente: '',
  folio: null,
  fecha: new Date().toISOString().split('T')[0],
  observaciones: ''
})

const fechasForm = ref({
  tipoCalculo: 'limite_pago',
  fechaInicial: new Date().toISOString().split('T')[0],
  diasHabiles: 15
})

const dictamenForm = ref({
  empresa: null,
  folio: '',
  tipoGenerador: 'solar',
  capacidad: null,
  fechaSolicitud: new Date().toISOString().split('T')[0]
})

const derechosForm = ref({
  empresa: null,
  tipoLicencia: 'nueva',
  anioFiscal: new Date().getFullYear()
})

// Computed
const totalDerechos = computed(() => {
  return derechosList.value.reduce((sum, derecho) => sum + derecho.total, 0)
})

// Métodos - Autorizaciones
const autorizarDocumento = async () => {
  if (!autorizacionForm.value.expediente) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'Por favor ingrese el número de expediente',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true)
  try {
    const spName = autorizacionForm.value.tipo === 'licencia'
      ? 'AUTORIZA_LICENCIA'
      : 'AUTORIZA_ANUNCIO'

    const response = await execute(
      spName,
      'padron_licencias',
      [
        { nombre: 'p_expediente', valor: autorizacionForm.value.expediente },
        { nombre: 'p_folio', valor: autorizacionForm.value.folio },
        { nombre: 'p_fecha', valor: autorizacionForm.value.fecha },
        { nombre: 'p_observaciones', valor: autorizacionForm.value.observaciones }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      autorizacionResult.value = {
        mensaje: `${autorizacionForm.value.tipo === 'licencia' ? 'Licencia' : 'Anuncio'} autorizado correctamente`,
        folio: response.result[0]?.folio || autorizacionForm.value.folio
      }
      showToast('success', 'Autorización exitosa')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const limpiarAutorizacion = () => {
  autorizacionForm.value = {
    tipo: 'licencia',
    expediente: '',
    folio: null,
    fecha: new Date().toISOString().split('T')[0],
    observaciones: ''
  }
  autorizacionResult.value = null
}

// Métodos - Cálculo de Fechas
const calcularFecha = async () => {
  if (!fechasForm.value.fechaInicial || !fechasForm.value.diasHabiles) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete la fecha inicial y días hábiles',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true)
  try {
    let spName = ''
    switch (fechasForm.value.tipoCalculo) {
      case 'limite_pago':
        spName = 'CALC_FECHA_LIMITE_PAGO'
        break
      case 'resolucion':
        spName = 'CALC_FECHA_RES'
        break
      case 'visita':
        spName = 'CALC_FECHA_VISITA'
        break
    }

    const response = await execute(
      spName,
      'padron_licencias',
      [
        { nombre: 'p_fecha_inicial', valor: fechasForm.value.fechaInicial },
        { nombre: 'p_dias_habiles', valor: fechasForm.value.diasHabiles }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]) {
      fechasResult.value = {
        fechaCalculada: response.result[0].fecha_calculada,
        diasTranscurridos: response.result[0].dias_transcurridos
      }
      showToast('success', 'Fecha calculada correctamente')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const verificarInhabil = async () => {
  if (!fechasForm.value.fechaInicial) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'Por favor seleccione una fecha',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true)
  try {
    const response = await execute(
      'CHECA_INHABIL',
      'padron_licencias',
      [
        { nombre: 'p_fecha', valor: fechasForm.value.fechaInicial }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]) {
      fechasResult.value = {
        fechaCalculada: fechasForm.value.fechaInicial,
        esInhabil: response.result[0].es_inhabil || false
      }
      showToast('info', 'Verificación completada')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

// Métodos - Dictámenes
const generarDictamen = async () => {
  if (!dictamenForm.value.empresa || !dictamenForm.value.capacidad) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete empresa y capacidad',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true)
  try {
    const response = await execute(
      'GENERAR_DICTAMEN_MICROGENERADORES',
      'padron_licencias',
      [
        { nombre: 'p_empresa', valor: dictamenForm.value.empresa },
        { nombre: 'p_folio', valor: dictamenForm.value.folio },
        { nombre: 'p_tipo_generador', valor: dictamenForm.value.tipoGenerador },
        { nombre: 'p_capacidad', valor: dictamenForm.value.capacidad },
        { nombre: 'p_fecha_solicitud', valor: dictamenForm.value.fechaSolicitud }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]) {
      dictamenResult.value = {
        folio: response.result[0].folio,
        fechaEmision: response.result[0].fecha_emision,
        estado: response.result[0].estado || 'GENERADO'
      }
      dictamenGenerado.value = true
      showToast('success', 'Dictamen generado exitosamente')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const imprimirDictamen = async () => {
  if (!dictamenResult.value?.folio) {
    showToast('warning', 'Genere un dictamen primero')
    return
  }

  setLoading(true)
  try {
    const response = await execute(
      'IMPRIMIR_DICTAMEN_MICROGENERADORES',
      'padron_licencias',
      [
        { nombre: 'p_folio', valor: dictamenResult.value.folio }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      showToast('success', 'Dictamen enviado a impresión')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const limpiarDictamen = () => {
  dictamenForm.value = {
    empresa: null,
    folio: '',
    tipoGenerador: 'solar',
    capacidad: null,
    fechaSolicitud: new Date().toISOString().split('T')[0]
  }
  dictamenResult.value = null
  dictamenGenerado.value = false
}

// Métodos - Derechos
const consultarDerechos = async () => {
  if (!derechosForm.value.empresa) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'Por favor ingrese el número de empresa',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true)
  try {
    const response = await execute(
      'GET_DERECHOS2',
      'padron_licencias',
      [
        { nombre: 'p_empresa', valor: derechosForm.value.empresa },
        { nombre: 'p_tipo_licencia', valor: derechosForm.value.tipoLicencia },
        { nombre: 'p_anio', valor: derechosForm.value.anioFiscal }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      derechosList.value = response.result.map(item => ({
        concepto: item.concepto || 'N/A',
        base: parseFloat(item.base) || 0,
        tasa: parseFloat(item.tasa) || 0,
        importe: parseFloat(item.importe) || 0,
        recargos: parseFloat(item.recargos) || 0,
        total: parseFloat(item.total) || 0
      }))
      showToast('success', 'Derechos consultados correctamente')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const actualizarConsulta = async () => {
  setLoading(true)
  try {
    await execute(
      'REFRESH_QUERY',
      'padron_licencias',
      [],
      'guadalajara'
    )
    showToast('success', 'Consulta actualizada')
    if (derechosForm.value.empresa) {
      await consultarDerechos()
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
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
}

.tab-button {
  padding: 12px 24px;
  background: transparent;
  border: none;
  border-bottom: 3px solid transparent;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s ease;
  color: #666;
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

.result-panel {
  margin-top: 20px;
  padding: 15px;
}

.alert {
  padding: 15px;
  border-radius: 4px;
  margin-bottom: 15px;
}

.alert-success {
  background-color: #d4edda;
  border: 1px solid #c3e6cb;
  color: #155724;
}

.alert-info {
  background-color: #d1ecf1;
  border: 1px solid #bee5eb;
  color: #0c5460;
}

.table-footer {
  background-color: #f8f9fa;
  font-weight: bold;
}

.text-right {
  text-align: right;
}
</style>
