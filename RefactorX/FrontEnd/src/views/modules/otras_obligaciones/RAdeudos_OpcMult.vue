<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="clipboard-list" />
      </div>
      <div class="module-view-info">
        <h1>{{ tituloModulo }}</h1>
        <p>Reporte de Opciones Múltiples de Adeudos - Otras Obligaciones</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda y documentación del módulo"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
        <button
          class="btn-municipal-secondary"
          @click="goBack"
          :disabled="isLoading"
        >
          <font-awesome-icon icon="arrow-left" />
          Salir
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Selector de Opción -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Selección de Opción
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="row g-3">
            <div class="col-12">
              <label class="municipal-form-label">
                <font-awesome-icon icon="tasks" class="me-1" />
                <strong>Opción de Proceso:</strong>
                <span class="required">*</span>
              </label>
              <select
                v-model="selectedOpcion"
                @change="onOpcionChange"
                class="municipal-form-control"
                :disabled="isLoading"
              >
                <option value="">-- Seleccione una opción --</option>
                <option value="1">
                  <font-awesome-icon icon="check-circle" /> P - DAR DE PAGADO
                </option>
                <option value="2">
                  <font-awesome-icon icon="hand-holding-heart" /> S - CONDONAR
                </option>
                <option value="3">
                  <font-awesome-icon icon="ban" /> C - CANCELAR
                </option>
                <option value="4">
                  <font-awesome-icon icon="clock" /> R - PRESCRIBIR
                </option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <!-- Búsqueda de Local -->
      <div class="municipal-card" v-if="selectedOpcion">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Búsqueda de Local
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="row g-3 align-items-end">
            <div class="col-md-3">
              <label class="municipal-form-label">
                <font-awesome-icon icon="hashtag" class="me-1" />
                <strong>Número de Local:</strong>
                <span class="required">*</span>
              </label>
              <input
                v-model="busqueda.numLocal"
                type="text"
                class="municipal-form-control"
                placeholder="Número"
                maxlength="3"
                @keyup.enter="focusLetra"
                @input="validateNumLocal"
              />
            </div>
            <div class="col-md-2">
              <label class="municipal-form-label">
                <font-awesome-icon icon="font" class="me-1" />
                <strong>Letra:</strong>
              </label>
              <input
                ref="letraInput"
                v-model="busqueda.letra"
                type="text"
                class="municipal-form-control"
                placeholder="Letra"
                maxlength="1"
                @keyup.enter="buscarConcesion"
              />
            </div>
            <div class="col-md-3">
              <button
                type="button"
                class="btn-municipal-primary w-100"
                @click="buscarConcesion"
                :disabled="!busqueda.numLocal || busqueda.numLocal === '0' || isLoading"
              >
                <font-awesome-icon icon="search" />
                Buscar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Datos de la Concesión -->
      <div class="municipal-card" v-if="datosGenerales">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="info-circle" />
            Datos del Local
          </h5>
          <span class="badge badge-purple">{{ datosGenerales.control }}</span>
        </div>

        <div class="municipal-card-body">
          <div class="info-grid">
            <div class="info-item" v-if="datosGenerales.concesionario">
              <label>
                <font-awesome-icon icon="user" class="me-1" />
                Concesionario:
              </label>
              <span>{{ datosGenerales.concesionario }}</span>
            </div>
            <div class="info-item" v-if="datosGenerales.ubicacion">
              <label>
                <font-awesome-icon icon="map-marker-alt" class="me-1" />
                Ubicación:
              </label>
              <span>{{ datosGenerales.ubicacion }}</span>
            </div>
            <div class="info-item" v-if="datosGenerales.superficie">
              <label>
                <font-awesome-icon icon="ruler-combined" class="me-1" />
                Superficie:
              </label>
              <span>{{ datosGenerales.superficie }} m²</span>
            </div>
            <div class="info-item" v-if="datosGenerales.fecha_inicio">
              <label>
                <font-awesome-icon icon="calendar-alt" class="me-1" />
                Fecha de Inicio:
              </label>
              <span>{{ formatDate(datosGenerales.fecha_inicio) }}</span>
            </div>
            <div class="info-item" v-if="datosGenerales.sector">
              <label>
                <font-awesome-icon icon="building" class="me-1" />
                Sector:
              </label>
              <span>{{ datosGenerales.sector }}</span>
            </div>
            <div class="info-item" v-if="datosGenerales.id_zona">
              <label>
                <font-awesome-icon icon="map" class="me-1" />
                Zona:
              </label>
              <span>{{ datosGenerales.id_zona }}</span>
            </div>
            <div class="info-item" v-if="datosGenerales.licencia">
              <label>
                <font-awesome-icon icon="file-alt" class="me-1" />
                Licencia:
              </label>
              <span>{{ datosGenerales.licencia }}</span>
            </div>
            <div class="info-item" v-if="datosGenerales.descrip_unidad">
              <label>
                <font-awesome-icon icon="tag" class="me-1" />
                Tipo de Unidad:
              </label>
              <span>{{ datosGenerales.descrip_unidad }}</span>
            </div>
            <div class="info-item" v-if="datosGenerales.descrip_stat">
              <label>
                <font-awesome-icon icon="flag" class="me-1" />
                Estado:
              </label>
              <span class="badge badge-purple">{{ datosGenerales.descrip_stat }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Parámetros de Ejecución (solo para opción Pagado) -->
      <div class="municipal-card" v-if="datosGenerales && selectedOpcion === '1'">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="cog" />
            Parámetros de Pago
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="row g-3">
            <div class="col-md-6">
              <label class="municipal-form-label">
                <font-awesome-icon icon="calendar" class="me-1" />
                <strong>Fecha de Pago:</strong>
                <span class="required">*</span>
              </label>
              <input
                v-model="parametros.fechaPago"
                type="date"
                class="municipal-form-control"
              />
            </div>
            <div class="col-md-6">
              <label class="municipal-form-label">
                <font-awesome-icon icon="building" class="me-1" />
                <strong>Recaudadora:</strong>
                <span class="required">*</span>
              </label>
              <select
                v-model="parametros.recaudadora"
                class="municipal-form-control"
              >
                <option value="">-- Seleccione --</option>
                <option
                  v-for="rec in recaudadoras"
                  :key="rec.id_rec"
                  :value="rec.id_rec"
                >
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
          </div>

          <div class="row g-3 mt-2">
            <div class="col-md-4">
              <label class="municipal-form-label">
                <font-awesome-icon icon="cash-register" class="me-1" />
                <strong>Caja:</strong>
                <span class="required">*</span>
              </label>
              <select
                v-model="parametros.caja"
                class="municipal-form-control"
              >
                <option value="">-- Seleccione --</option>
                <option
                  v-for="caja in cajas"
                  :key="caja.caja"
                  :value="caja.caja"
                >
                  {{ caja.caja }}
                </option>
              </select>
            </div>
            <div class="col-md-4">
              <label class="municipal-form-label">
                <font-awesome-icon icon="sort-numeric-up" class="me-1" />
                <strong>Consecutivo Operación:</strong>
                <span class="required">*</span>
              </label>
              <input
                v-model.number="parametros.consecutivo"
                type="number"
                class="municipal-form-control"
                min="1"
                placeholder="Consecutivo"
              />
            </div>
            <div class="col-md-4">
              <label class="municipal-form-label">
                <font-awesome-icon icon="receipt" class="me-1" />
                <strong>Folio Recibo:</strong>
                <span class="required">*</span>
              </label>
              <input
                v-model="parametros.folioRecibo"
                type="text"
                class="municipal-form-control"
                maxlength="20"
                placeholder="Folio"
              />
            </div>
          </div>
        </div>
      </div>

      <!-- Grid de Adeudos -->
      <div class="municipal-card" v-if="adeudos.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list-alt" />
            Adeudos Disponibles
          </h5>
          <span class="badge badge-purple">{{ adeudosSeleccionados.length }} / {{ adeudos.length }} seleccionados</span>
        </div>

        <div class="municipal-card-body">
          <div class="alert alert-info mb-3">
            <font-awesome-icon icon="info-circle" class="me-2" />
            <strong>Instrucciones:</strong> Seleccione los adeudos que desea procesar marcando las casillas de verificación.
          </div>

          <!-- Tabla de adeudos -->
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th style="width: 5%;">
                    <input
                      type="checkbox"
                      :checked="todosSeleccionados"
                      @change="toggleTodos"
                      title="Seleccionar todos"
                    />
                  </th>
                  <th style="width: 10%;">
                    <font-awesome-icon icon="calendar-alt" class="me-1" />
                    Año
                  </th>
                  <th style="width: 15%;">
                    <font-awesome-icon icon="calendar" class="me-1" />
                    Mes
                  </th>
                  <th style="width: 15%;">
                    <font-awesome-icon icon="clock" class="me-1" />
                    Periodo
                  </th>
                  <th style="width: 20%; text-align: right;">
                    <font-awesome-icon icon="dollar-sign" class="me-1" />
                    Importe
                  </th>
                  <th style="width: 20%; text-align: right;">
                    <font-awesome-icon icon="percent" class="me-1" />
                    Recargos
                  </th>
                  <th style="width: 15%; text-align: right;">
                    <font-awesome-icon icon="calculator" class="me-1" />
                    Total
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(adeudo, idx) in adeudos" :key="idx">
                  <td class="text-center">
                    <input
                      type="checkbox"
                      v-model="adeudo.seleccionado"
                    />
                  </td>
                  <td>{{ adeudo.axo }}</td>
                  <td>{{ getMesNombre(adeudo.mes) }}</td>
                  <td>{{ formatDate(adeudo.periodo) }}</td>
                  <td class="text-end">{{ formatCurrency(adeudo.importe) }}</td>
                  <td class="text-end">{{ formatCurrency(adeudo.recargo) }}</td>
                  <td class="text-end">
                    <strong>{{ formatCurrency(adeudo.importe + adeudo.recargo) }}</strong>
                  </td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="municipal-table-footer">
                  <td colspan="4" class="text-end"><strong>TOTALES:</strong></td>
                  <td class="text-end"><strong>{{ formatCurrency(totalImporte) }}</strong></td>
                  <td class="text-end"><strong>{{ formatCurrency(totalRecargos) }}</strong></td>
                  <td class="text-end"><strong>{{ formatCurrency(totalGeneral) }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Botones de acción -->
          <div class="d-flex gap-2 mt-4">
            <button
              type="button"
              class="btn-municipal-primary"
              @click="ejecutarAccion"
              :disabled="!canEjecutar || saving"
            >
              <font-awesome-icon :icon="saving ? 'spinner' : 'check'" :spin="saving" />
              {{ saving ? 'Procesando...' : textoBotonEjecutar }}
            </button>
            <button
              type="button"
              class="btn-municipal-secondary"
              @click="limpiarBusqueda"
              :disabled="saving"
            >
              <font-awesome-icon icon="times" />
              Cancelar
            </button>
          </div>
        </div>
      </div>

      <!-- Mensaje cuando no hay adeudos -->
      <div class="municipal-card" v-else-if="datosGenerales && buscado">
        <div class="municipal-card-body">
          <div class="text-center text-muted py-5">
            <font-awesome-icon icon="info-circle" size="3x" class="mb-3 text-secondary" />
            <p class="mb-0">No se encontraron adeudos para este local.</p>
          </div>
        </div>
      </div>
    </div>
    <!-- /module-view-content -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'RAdeudos_OpcMult'"
      :moduleName="'otras_obligaciones'"
      @close="closeDocumentation"
    />
  </div>
  <!-- /module-view -->
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

// Router
const router = useRouter()

// Composables
const { execute } = useApi()
const { isLoading, startLoading, stopLoading } = useGlobalLoading()
const { toast, showToast, hideToast, handleApiError } = useLicenciasErrorHandler()

// Estado
const showDocumentation = ref(false)
const recaudadoras = ref([])
const cajas = ref([])
const selectedOpcion = ref('')
const busqueda = ref({
  numLocal: '',
  letra: ''
})
const datosGenerales = ref(null)
const adeudos = ref([])
const saving = ref(false)
const buscado = ref(false)

// Referencias
const letraInput = ref(null)

// Parámetros para operación Pagado
const parametros = ref({
  fechaPago: new Date().toISOString().split('T')[0],
  recaudadora: '',
  caja: '',
  consecutivo: null,
  folioRecibo: ''
})

// Computed
const tituloModulo = computed(() => {
  if (!selectedOpcion.value) return 'Reporte Opciones Múltiples de Adeudos'

  const opciones = {
    '1': 'REPORTE - DAR DE PAGADO ADEUDOS',
    '2': 'REPORTE - CONDONAR ADEUDOS',
    '3': 'REPORTE - CANCELAR ADEUDOS',
    '4': 'REPORTE - PRESCRIBIR ADEUDOS'
  }

  return opciones[selectedOpcion.value] || 'Reporte Opciones Múltiples de Adeudos'
})

const textoBotonEjecutar = computed(() => {
  const textos = {
    '1': 'Ejecutar Pagado',
    '2': 'Ejecutar Condonación',
    '3': 'Ejecutar Cancelación',
    '4': 'Ejecutar Prescripción'
  }
  return textos[selectedOpcion.value] || 'Ejecutar'
})

const adeudosSeleccionados = computed(() => {
  return adeudos.value.filter(a => a.seleccionado)
})

const todosSeleccionados = computed(() => {
  return adeudos.value.length > 0 && adeudos.value.every(a => a.seleccionado)
})

const totalImporte = computed(() => {
  return adeudosSeleccionados.value.reduce((sum, a) => sum + (a.importe || 0), 0)
})

const totalRecargos = computed(() => {
  return adeudosSeleccionados.value.reduce((sum, a) => sum + (a.recargo || 0), 0)
})

const totalGeneral = computed(() => {
  return totalImporte.value + totalRecargos.value
})

const canEjecutar = computed(() => {
  if (adeudosSeleccionados.value.length === 0 || saving.value) {
    return false
  }

  // Si es opción Pagado, validar parámetros adicionales
  if (selectedOpcion.value === '1') {
    return parametros.value.fechaPago &&
           parametros.value.recaudadora &&
           parametros.value.caja &&
           parametros.value.consecutivo &&
           parametros.value.folioRecibo
  }

  return true
})

// Métodos
const goBack = () => {
  router.push('/otras_obligaciones')
}

const openDocumentation = () => {
  showDocumentation.value = true
}

const closeDocumentation = () => {
  showDocumentation.value = false
}

const focusLetra = () => {
  if (letraInput.value) {
    letraInput.value.focus()
  }
}

const validateNumLocal = () => {
  // Validar que solo sean números
  busqueda.value.numLocal = busqueda.value.numLocal.replace(/[^0-9]/g, '')
}

const formatCurrency = (value) => {
  if (value === null || value === undefined) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('es-MX', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}

const getMesNombre = (mes) => {
  const meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ]
  return meses[mes - 1] || mes
}

const toggleTodos = () => {
  const nuevoEstado = !todosSeleccionados.value
  adeudos.value.forEach(a => a.seleccionado = nuevoEstado)
}

// Cargar recaudadoras
const loadRecaudadoras = async () => {
  try {
    const response = await execute(
      'con34_rdetade_021',
      'otras_obligaciones',
      [],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      recaudadoras.value = response.result
      if (recaudadoras.value.length > 0) {
        parametros.value.recaudadora = recaudadoras.value[0].id_rec
      }
    } else {
      recaudadoras.value = []
    }
  } catch (error) {
    console.warn('Error al cargar recaudadoras:', error)
    recaudadoras.value = []
  }
}

// Cargar cajas
const loadCajas = async () => {
  try {
    // Usar valores por defecto
    cajas.value = [{ caja: '01' }, { caja: '02' }]
    parametros.value.caja = '01'
  } catch (error) {
    console.warn('Error al cargar cajas:', error)
  }
}

// Evento al cambiar la opción
const onOpcionChange = () => {
  limpiarBusqueda()
}

// Buscar concesión
const buscarConcesion = async () => {
  if (!selectedOpcion.value) {
    showToast('warning', 'Debe seleccionar una opción')
    return
  }

  // Validar número de local
  if (!busqueda.value.numLocal || busqueda.value.numLocal === '0') {
    showToast('warning', 'Falta el dato del NUMERO DE LOCAL, intentalo de nuevo')
    return
  }

  // Construir el control: número-letra o solo número
  const control = busqueda.value.letra
    ? `${busqueda.value.numLocal}-${busqueda.value.letra}`
    : busqueda.value.numLocal

  startLoading('Buscando local...')

  try {
    // Buscar datos generales (usando la tabla 3 para mercados)
    const response = await execute(
      'con34_1datos_03',
      'otras_obligaciones',
      [
        { nombre: 'par_control', valor: control, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      datosGenerales.value = response.result[0]
      buscado.value = true
      showToast('success', 'Local encontrado')

      // Buscar adeudos
      await buscarAdeudos(datosGenerales.value.id_34_datos)

      // Verificar si encontró adeudos
      if (adeudos.value.length === 0) {
        showToast('info', 'No tiene adeudo alguno al periodo de vencimiento actual')
      }
    } else {
      showToast('error', 'No existe LOCAL con este dato, intentalo de nuevo')
      datosGenerales.value = null
      adeudos.value = []
      buscado.value = true
    }
  } catch (error) {
    handleApiError(error)
    datosGenerales.value = null
    adeudos.value = []
    buscado.value = true
  } finally {
    stopLoading()
  }
}

// Buscar adeudos
const buscarAdeudos = async (idDatos) => {
  try {
    const response = await execute(
      'con34_rdetade_021',
      'otras_obligaciones',
      [
        { nombre: 'p_id_datos', valor: idDatos, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      adeudos.value = response.result.map(a => ({
        ...a,
        seleccionado: false
      }))
      showToast('success', `${adeudos.value.length} adeudo(s) encontrado(s)`)
    } else {
      adeudos.value = []
    }
  } catch (error) {
    handleApiError(error)
    adeudos.value = []
  }
}

// Ejecutar acción
const ejecutarAccion = async () => {
  if (adeudosSeleccionados.value.length === 0) {
    showToast('warning', 'Debe seleccionar al menos un adeudo')
    return
  }

  // Obtener el código de status según la opción
  const statusCodes = {
    '1': 'P', // Pagado
    '2': 'S', // Condonado
    '3': 'C', // Cancelado
    '4': 'R'  // Prescrito
  }
  const statusCode = statusCodes[selectedOpcion.value]

  // Construir mensaje de confirmación
  const accionTexto = {
    '1': 'PAGAR',
    '2': 'CONDONAR',
    '3': 'CANCELAR',
    '4': 'PRESCRIBIR'
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: `¿Confirmar ${accionTexto[selectedOpcion.value]} adeudos?`,
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se procesarán <strong>${adeudosSeleccionados.value.length}</strong> adeudo(s):</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Total Importe:</strong> ${formatCurrency(totalImporte.value)}</li>
          <li style="margin: 5px 0;"><strong>Total Recargos:</strong> ${formatCurrency(totalRecargos.value)}</li>
          <li style="margin: 5px 0;"><strong>TOTAL GENERAL:</strong> ${formatCurrency(totalGeneral.value)}</li>
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: `Sí, ${accionTexto[selectedOpcion.value].toLowerCase()}`,
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  saving.value = true
  let procesados = 0
  let errores = 0
  const mensajesError = []

  try {
    for (let i = 0; i < adeudosSeleccionados.value.length; i++) {
      const adeudo = adeudosSeleccionados.value[i]

      try {
        const params = [
          { nombre: 'par_id_datos', valor: adeudo.registro, tipo: 'integer' },
          { nombre: 'par_axo', valor: adeudo.axo, tipo: 'integer' },
          { nombre: 'par_mes', valor: adeudo.mes, tipo: 'integer' },
          { nombre: 'par_fecha', valor: parametros.value.fechaPago, tipo: 'date' },
          { nombre: 'par_id_rec', valor: parametros.value.recaudadora || 0, tipo: 'integer' },
          { nombre: 'par_caja', valor: parametros.value.caja || '', tipo: 'string' },
          { nombre: 'par_consec', valor: parametros.value.consecutivo || 0, tipo: 'integer' },
          { nombre: 'par_folio_rcbo', valor: parametros.value.folioRecibo || '', tipo: 'string' },
          { nombre: 'par_tab', valor: 'E', tipo: 'string' },
          { nombre: 'par_status', valor: statusCode, tipo: 'string' },
          { nombre: 'par_opc', valor: 'B', tipo: 'string' }
        ]

        const response = await execute(
          'upd34_ade_01',
          'otras_obligaciones',
          params,
          'guadalajara'
        )

        // En Delphi, status = 0 indica éxito
        if (response && response.result && response.result[0]?.status === 0) {
          procesados++
        } else {
          errores++
          const mensaje = response?.result?.[0]?.concepto_status || 'Error desconocido'
          mensajesError.push(`${adeudo.axo}/${getMesNombre(adeudo.mes)}: ${mensaje}`)
        }
      } catch (error) {
        errores++
        mensajesError.push(`${adeudo.axo}/${getMesNombre(adeudo.mes)}: ${error.message || 'Error al procesar'}`)
      }
    }

    // Mostrar resultado
    if (procesados > 0 && errores === 0) {
      await Swal.fire({
        icon: 'success',
        title: '¡Proceso exitoso!',
        html: `
          <div style="text-align: center;">
            <p style="font-size: 1.1em; margin: 10px 0;">
              Se procesaron correctamente <strong>${procesados}</strong> adeudo(s).
            </p>
          </div>
        `,
        confirmButtonColor: '#ea8215',
        timer: 3000
      })

      showToast('success', `${procesados} adeudo(s) procesado(s)`)

      // Recargar adeudos
      await buscarAdeudos(datosGenerales.value.id_34_datos)
    } else if (procesados > 0 && errores > 0) {
      await Swal.fire({
        icon: 'warning',
        title: 'Proceso parcial',
        html: `
          <div style="text-align: left; padding: 0 20px;">
            <p><strong>Procesados:</strong> ${procesados}</p>
            <p><strong>Errores:</strong> ${errores}</p>
            <hr>
            <p style="margin-top: 10px;"><strong>Detalles de errores:</strong></p>
            <ul style="max-height: 200px; overflow-y: auto; font-size: 0.9em;">
              ${mensajesError.map(msg => `<li>${msg}</li>`).join('')}
            </ul>
          </div>
        `,
        confirmButtonColor: '#ea8215'
      })

      showToast('warning', `${procesados} procesado(s), ${errores} error(es)`)

      // Recargar adeudos
      await buscarAdeudos(datosGenerales.value.id_34_datos)
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al procesar',
        html: `
          <div style="text-align: left; padding: 0 20px;">
            <p>No se pudo procesar ningún adeudo.</p>
            <hr>
            <p style="margin-top: 10px;"><strong>Detalles de errores:</strong></p>
            <ul style="max-height: 200px; overflow-y: auto; font-size: 0.9em;">
              ${mensajesError.map(msg => `<li>${msg}</li>`).join('')}
            </ul>
          </div>
        `,
        confirmButtonColor: '#ea8215'
      })

      showToast('error', 'No se procesaron adeudos')
    }
  } catch (error) {
    handleApiError(error)
    await Swal.fire({
      icon: 'error',
      title: 'Error de conexión',
      text: 'No se pudieron procesar los adeudos',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    saving.value = false
  }
}

// Limpiar búsqueda
const limpiarBusqueda = () => {
  busqueda.value.numLocal = ''
  busqueda.value.letra = ''
  datosGenerales.value = null
  adeudos.value = []
  buscado.value = false
}

// Lifecycle
onMounted(() => {
  loadRecaudadoras()
  loadCajas()
})
</script>
