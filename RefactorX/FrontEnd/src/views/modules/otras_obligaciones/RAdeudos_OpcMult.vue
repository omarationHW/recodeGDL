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
          v-if="adeudos.length > 0"
          class="btn-municipal-success"
          @click="imprimirReporte"
        >
          <font-awesome-icon icon="print" />
          Imprimir
        </button>
        <button
          v-if="adeudos.length > 0"
          class="btn-municipal-secondary"
          @click="exportarExcel"
        >
          <font-awesome-icon icon="file-excel" />
          Excel
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
        <button
          class="btn-municipal-secondary"
          @click="goBack"
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
              <strong>Concesionario:</strong>
              <span>{{ datosGenerales.concesionario }}</span>
            </div>
            <div class="info-item" v-if="datosGenerales.ubicacion">
              <strong>Ubicación:</strong>
              <span>{{ datosGenerales.ubicacion }}</span>
            </div>
            <div class="info-item" v-if="datosGenerales.superficie">
              <strong>Superficie:</strong>
              <span>{{ datosGenerales.superficie }} m²</span>
            </div>
            <div class="info-item" v-if="datosGenerales.fecha_inicio">
              <strong>Fecha de Inicio:</strong>
              <span>{{ formatDate(datosGenerales.fecha_inicio) }}</span>
            </div>
            <div class="info-item" v-if="datosGenerales.sector">
              <strong>Sector:</strong>
              <span>{{ datosGenerales.sector }}</span>
            </div>
            <div class="info-item" v-if="datosGenerales.id_zona">
              <strong>Zona:</strong>
              <span>{{ datosGenerales.id_zona }}</span>
            </div>
            <div class="info-item" v-if="datosGenerales.licencia">
              <strong>Licencia:</strong>
              <span>{{ datosGenerales.licencia }}</span>
            </div>
            <div class="info-item" v-if="datosGenerales.descrip_stat">
              <strong>Estado:</strong>
              <span class="badge badge-purple">{{ datosGenerales.descrip_stat }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Parámetros de Pago (solo para opción Pagado) -->
      <div class="municipal-card" v-if="datosGenerales && selectedOpcion === '1'">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="cog" />
            Parámetros de Pago
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Fecha de Pago:</label>
              <input v-model="parametros.fechaPago" type="date" class="municipal-form-control" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Recaudadora:</label>
              <select v-model.number="parametros.recaudadora" class="municipal-form-control">
                <option :value="0">0 - SIN RECAUDADORA</option>
                <option :value="1">1 - RECAUDADORA 1</option>
                <option :value="2">2 - RECAUDADORA 2</option>
                <option :value="3">3 - RECAUDADORA 3</option>
                <option :value="4">4 - RECAUDADORA 4</option>
                <option :value="5">5 - RECAUDADORA 5</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Caja:</label>
              <input v-model="parametros.caja" type="text" class="municipal-form-control" maxlength="5" placeholder="01" />
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Consecutivo:</label>
              <input v-model.number="parametros.consecutivo" type="number" class="municipal-form-control" min="0" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Folio Recibo:</label>
              <input v-model="parametros.folioRecibo" type="text" class="municipal-form-control" maxlength="20" />
            </div>
          </div>
        </div>
      </div>

      <!-- Grid de Adeudos -->
      <div class="municipal-card" v-if="adeudos.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list-alt" />
            Adeudos Disponibles ({{ adeudos.length }})
          </h5>
          <span class="badge badge-purple">{{ adeudosSeleccionados.length }} seleccionados</span>
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
                  <th class="text-center">Año</th>
                  <th class="text-center">Mes</th>
                  <th class="text-center">Periodo</th>
                  <th class="text-right">Importe</th>
                  <th class="text-right">Recargos</th>
                  <th class="text-right">Total</th>
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
                  <td class="text-center">{{ adeudo.axo }}</td>
                  <td class="text-center">{{ getMesNombre(adeudo.mes) }}</td>
                  <td class="text-center">{{ formatDate(adeudo.periodo) }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.importe) }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.recargo) }}</td>
                  <td class="text-right">
                    <strong>{{ formatCurrency(adeudo.importe + adeudo.recargo) }}</strong>
                  </td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="municipal-table-footer">
                  <td colspan="4" class="text-right"><strong>TOTALES:</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totalImporte) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totalRecargos) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totalGeneral) }}</strong></td>
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
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { usePdfExport } from '@/composables/usePdfExport'
import Swal from 'sweetalert2'
import * as XLSX from 'xlsx'

const router = useRouter()
const BASE_DB = 'otras_obligaciones'
const { execute } = useApi()
const { isLoading, showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()
const { exportToPdf } = usePdfExport()

// Estado
const showDocumentation = ref(false)
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

// Parámetros de pago
const parametros = ref({
  fechaPago: new Date().toISOString().split('T')[0],
  recaudadora: 0,
  caja: '01',
  consecutivo: 0,
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
  return adeudosSeleccionados.value.length > 0 && !saving.value
})

// Métodos
const goBack = () => {
  router.push('/otras-obligaciones/menu')
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

  if (!busqueda.value.numLocal || busqueda.value.numLocal === '0') {
    showToast('warning', 'Falta el dato del NUMERO DE LOCAL, intentalo de nuevo')
    return
  }

  const control = busqueda.value.letra
    ? `${busqueda.value.numLocal}-${busqueda.value.letra}`
    : busqueda.value.numLocal

  showLoading('Buscando local...')

  try {
    const response = await execute(
      'gconsulta2_sp_busca_cont',
      BASE_DB,
      [
        { nombre: 'par_tab', valor: 3, tipo: 'integer' },
        { nombre: 'par_control', valor: control, tipo: 'varchar' }
      ],
      'guadalajara'
    )

    hideLoading()

    if (response?.result?.length > 0 && response.result[0].status !== -1) {
      datosGenerales.value = response.result[0]
      datosGenerales.value.control = control
      buscado.value = true
      showToast('success', 'Local encontrado')

      await buscarAdeudos(datosGenerales.value.id_datos)

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
    hideLoading()
    handleApiError(error)
    datosGenerales.value = null
    adeudos.value = []
    buscado.value = true
  }
}

// Buscar adeudos
const buscarAdeudos = async (idDatos) => {
  try {
    const response = await execute(
      'con34_rdetade_021',
      BASE_DB,
      [
        { nombre: 'p_id_datos', valor: idDatos, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response?.result?.length > 0) {
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
          { nombre: 'par_id_datos', valor: datosGenerales.value.id_datos, tipo: 'integer' },
          { nombre: 'par_axo', valor: adeudo.axo, tipo: 'integer' },
          { nombre: 'par_mes', valor: adeudo.mes, tipo: 'integer' },
          { nombre: 'par_fecha', valor: parametros.value.fechaPago, tipo: 'date' },
          { nombre: 'par_id_rec', valor: parametros.value.recaudadora, tipo: 'integer' },
          { nombre: 'par_caja', valor: parametros.value.caja, tipo: 'string' },
          { nombre: 'par_consec', valor: parametros.value.consecutivo, tipo: 'integer' },
          { nombre: 'par_folio_rcbo', valor: parametros.value.folioRecibo, tipo: 'string' },
          { nombre: 'par_tab', valor: '3', tipo: 'string' },
          { nombre: 'par_status', valor: statusCode, tipo: 'string' },
          { nombre: 'par_opc', valor: 'B', tipo: 'string' }
        ]

        const response = await execute(
          'upd34_ade_01',
          BASE_DB,
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
      await buscarAdeudos(datosGenerales.value.id_datos)
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
      await buscarAdeudos(datosGenerales.value.id_datos)
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

// Imprimir reporte
const imprimirReporte = () => {
  if (adeudos.value.length === 0) {
    showToast('warning', 'No hay datos para imprimir')
    return
  }

  const columns = [
    { header: 'Año', key: 'axo', type: 'number' },
    { header: 'Mes', key: 'mesNombre', type: 'string' },
    { header: 'Periodo', key: 'periodo', type: 'string' },
    { header: 'Importe', key: 'importe', type: 'currency' },
    { header: 'Recargos', key: 'recargo', type: 'currency' },
    { header: 'Total', key: 'total', type: 'currency' }
  ]

  const data = adeudos.value.map(a => ({
    axo: a.axo,
    mesNombre: getMesNombre(a.mes),
    periodo: formatDate(a.periodo),
    importe: a.importe,
    recargo: a.recargo,
    total: a.importe + a.recargo
  }))

  const opcionNombre = {
    '1': 'DAR DE PAGADO',
    '2': 'CONDONAR',
    '3': 'CANCELAR',
    '4': 'PRESCRIBIR'
  }

  exportToPdf(data, columns, {
    title: `Adeudos - ${opcionNombre[selectedOpcion.value] || 'Opciones Múltiples'}`,
    subtitle: `Control: ${datosGenerales.value?.control || ''} - ${datosGenerales.value?.concesionario || ''} - Total: ${formatCurrency(totalGeneral.value)}`,
    orientation: 'landscape'
  })
}

// Exportar a Excel
const exportarExcel = () => {
  if (adeudos.value.length === 0) {
    showToast('warning', 'No hay datos para exportar')
    return
  }

  try {
    const exportData = adeudos.value.map(a => ({
      'Año': a.axo,
      'Mes': getMesNombre(a.mes),
      'Periodo': formatDate(a.periodo),
      'Importe': a.importe,
      'Recargos': a.recargo,
      'Total': a.importe + a.recargo
    }))

    exportData.push({
      'Año': '',
      'Mes': '',
      'Periodo': 'TOTALES:',
      'Importe': totalImporte.value,
      'Recargos': totalRecargos.value,
      'Total': totalGeneral.value
    })

    const ws = XLSX.utils.json_to_sheet(exportData)
    const wb = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(wb, ws, 'Adeudos')

    const control = datosGenerales.value?.control || 'Sin_Control'
    XLSX.writeFile(wb, `RAdeudos_OpcMult_${control}_${new Date().toISOString().slice(0,10)}.xlsx`)
    showToast('success', 'Archivo exportado')
  } catch (error) {
    showToast('error', 'Error al exportar')
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

</script>
