<template>
  <div class="module-view">
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="calendar-check" />
      </div>
      <div class="module-view-info">
        <h1>Actualización de Periodos en Pagos</h1>
        <p>Aseo Contratado - Actualizar y corregir periodos asociados a pagos registrados</p>
      </div>
      <button
        type="button"
        class="btn-help-icon"
        @click="mostrarAyuda = true"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>
<div class="municipal-card shadow-sm mb-4">
      <div class="municipal-card-header">
        <h5>Paso 1: Búsqueda de Pago</h5>
      </div>
      <div class="municipal-card-body">
        <div class="row">
          <div class="col-md-3">
            <label class="municipal-form-label">Tipo de Búsqueda</label>
            <select class="municipal-form-control" v-model="tipoBusqueda">
              <option value="recibo">Por Número de Recibo</option>
              <option value="contrato">Por Contrato</option>
              <option value="fecha">Por Rango de Fechas</option>
            </select>
          </div>
          <div class="col-md-3" v-if="tipoBusqueda === 'recibo'">
            <label class="municipal-form-label">Número de Recibo</label>
            <input type="text" class="municipal-form-control" v-model="busqueda.recibo"
              @keyup.enter="buscarPagos" placeholder="Ej: 12345" />
          </div>
          <div class="col-md-3" v-if="tipoBusqueda === 'contrato'">
            <label class="municipal-form-label">Número de Contrato</label>
            <input type="text" class="municipal-form-control" v-model="busqueda.contrato"
              @keyup.enter="buscarPagos" placeholder="Ej: 001-2024" />
          </div>
          <div class="col-md-3" v-if="tipoBusqueda === 'fecha'">
            <label class="municipal-form-label">Fecha Desde</label>
            <input type="date" class="municipal-form-control" v-model="busqueda.fechaDesde" />
          </div>
          <div class="col-md-3" v-if="tipoBusqueda === 'fecha'">
            <label class="municipal-form-label">Fecha Hasta</label>
            <input type="date" class="municipal-form-control" v-model="busqueda.fechaHasta" />
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">&nbsp;</label>
            <button class="btn-municipal-primary w-100" @click="buscarPagos" :disabled="cargando">
              <font-awesome-icon icon="search" /> Buscar
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="pagosEncontrados.length > 0" class="municipal-card shadow-sm mb-4">
      <div class="municipal-card-header bg-light d-flex justify-content-between">
        <h6 class="mb-0">Pagos Encontrados ({{ pagosEncontrados.length }})</h6>
        <div>
          <button class="btn btn-sm btn-success me-2" @click="seleccionarTodos">
            <font-awesome-icon icon="check-double" /> Seleccionar Todos
          </button>
          <button class="btn btn-sm btn-warning" @click="limpiarSeleccion">
            <font-awesome-icon icon="eraser" /> Limpiar
          </button>
        </div>
      </div>
      <div class="municipal-card-body">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead>
              <tr>
                <th style="width: 40px;">
                  <input type="checkbox" class="form-check-input" v-model="seleccionarTodo"
                    @change="toggleSeleccionTodos" />
                </th>
                <th>Recibo</th>
                <th>Contrato</th>
                <th>Contribuyente</th>
                <th>Fecha Pago</th>
                <th>Periodo Actual</th>
                <th class="text-end">Monto</th>
                <th>Forma Pago</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="pago in pagosEncontrados" :key="pago.control_pago"
                  :class="{ 'table-warning': pagosSeleccionados.includes(pago.control_pago) }">
                <td>
                  <input type="checkbox" class="form-check-input"
                    :value="pago.control_pago" v-model="pagosSeleccionados" />
                </td>
                <td>{{ pago.num_recibo }}</td>
                <td>{{ pago.num_contrato }}</td>
                <td>{{ pago.contribuyente }}</td>
                <td>{{ formatFecha(pago.fecha_pago) }}</td>
                <td>
                  <span class="badge badge-info">{{ pago.periodo_actual || 'Sin asignar' }}</span>
                </td>
                <td class="text-end">${{ formatCurrency(pago.monto) }}</td>
                <td>{{ pago.forma_pago }}</td>
                <td>
                  <span class="badge" :class="pago.status === 'A' ? 'bg-success' : 'bg-danger'">
                    {{ pago.status === 'A' ? 'Activo' : 'Cancelado' }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <div v-if="pagosSeleccionados.length > 0" class="municipal-card shadow-sm mb-4">
      <div class="municipal-card-header">
        <h5>Paso 2: Actualización de Periodos ({{ pagosSeleccionados.length }} seleccionados)</h5>
      </div>
      <div class="municipal-card-body">
        <div class="alert alert-warning">
          <font-awesome-icon icon="exclamation-triangle" class="me-2" />
          <strong>Atención:</strong> Esta operación actualizará los periodos de los pagos seleccionados.
          Verifique cuidadosamente antes de proceder.
        </div>

        <div class="row mb-4">
          <div class="col-md-3">
            <label class="municipal-form-label">Tipo de Actualización</label>
            <select class="municipal-form-control" v-model="tipoActualizacion">
              <option value="periodo_fijo">Periodo Fijo</option>
              <option value="periodo_calculado">Calcular Automáticamente</option>
              <option value="periodo_manual">Asignación Manual</option>
            </select>
          </div>
          <div class="col-md-3" v-if="tipoActualizacion === 'periodo_fijo'">
            <label class="municipal-form-label">Año</label>
            <input type="number" class="municipal-form-control" v-model.number="periodoNuevo.anio"
              min="2000" :max="new Date().getFullYear()" />
          </div>
          <div class="col-md-3" v-if="tipoActualizacion === 'periodo_fijo'">
            <label class="municipal-form-label">Mes</label>
            <select class="municipal-form-control" v-model="periodoNuevo.mes">
              <option v-for="n in 12" :key="n" :value="n">{{ meses[n-1] }}</option>
            </select>
          </div>
          <div class="col-md-3" v-if="tipoActualizacion === 'periodo_calculado'">
            <label class="municipal-form-label">Criterio de Cálculo</label>
            <select class="municipal-form-control" v-model="criterioCalculo">
              <option value="fecha_pago">Basado en Fecha de Pago</option>
              <option value="ultimo_periodo">Último Periodo Pagado</option>
              <option value="fecha_vencimiento">Fecha de Vencimiento</option>
            </select>
          </div>
        </div>

        <div v-if="tipoActualizacion === 'periodo_fijo'" class="mb-3">
          <strong>Periodo a asignar:</strong>
          <span class="badge bg-primary ms-2">
            {{ periodoNuevo.anio }}-{{ String(periodoNuevo.mes).padStart(2, '0') }}
          </span>
        </div>

        <div class="row">
          <div class="col-md-12">
            <label class="municipal-form-label">Motivo de la Actualización</label>
            <textarea class="municipal-form-control" v-model="motivoActualizacion" rows="3"
              placeholder="Describa el motivo de esta actualización..."></textarea>
          </div>
        </div>

        <div class="d-flex justify-content-end mt-4">
          <button class="btn-municipal-secondary me-2" @click="cancelarActualizacion">
            <font-awesome-icon icon="times" /> Cancelar
          </button>
          <button class="btn-municipal-info" @click="confirmarActualizacion"
            :disabled="!validarActualizacion()">
            <font-awesome-icon icon="save" /> Actualizar Periodos
          </button>
        </div>
      </div>
    </div>

    <div v-if="historialActualizaciones.length > 0" class="municipal-card">
      <div class="municipal-card-header">
        <h5>Historial de Actualizaciones Recientes</h5>
      </div>
      <div class="municipal-card-body">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead>
              <tr>
                <th>Fecha</th>
                <th>Usuario</th>
                <th>Pagos Actualizados</th>
                <th>Tipo</th>
                <th>Periodo Asignado</th>
                <th>Motivo</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="hist in historialActualizaciones" :key="hist.id">
                <td>{{ formatFecha(hist.fecha) }}</td>
                <td>{{ hist.usuario }}</td>
                <td>{{ hist.cantidad_pagos }}</td>
                <td>{{ hist.tipo_actualizacion }}</td>
                <td>{{ hist.periodo_asignado }}</td>
                <td>{{ hist.motivo }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Actualización de Periodos en Pagos">
      <h6>Descripción</h6>
      <p>Permite actualizar y corregir los periodos asociados a pagos ya registrados en el sistema.</p>
      <h6>Tipos de Actualización</h6>
      <ul>
        <li><strong>Periodo Fijo:</strong> Asigna un periodo específico a todos los pagos seleccionados</li>
        <li><strong>Calcular Automáticamente:</strong> El sistema calcula el periodo basándose en criterios configurables</li>
        <li><strong>Asignación Manual:</strong> Permite asignar periodos individuales a cada pago</li>
      </ul>
      <h6>Casos de Uso</h6>
      <ul>
        <li>Corrección de periodos mal capturados</li>
        <li>Reasignación de pagos a periodos correctos</li>
        <li>Actualización masiva de periodos por cambio de criterio</li>
      </ul>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useToast } from '@/composables/useToast'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { handleError } = useLicenciasErrorHandler()
const { showToast } = useToast()

const cargando = ref(false)
const mostrarAyuda = ref(false)
const tipoBusqueda = ref('recibo')
const tipoActualizacion = ref('periodo_fijo')
const criterioCalculo = ref('fecha_pago')
const seleccionarTodo = ref(false)

const busqueda = ref({
  recibo: '',
  contrato: '',
  fechaDesde: '',
  fechaHasta: new Date().toISOString().split('T')[0]
})

const pagosEncontrados = ref([])
const pagosSeleccionados = ref([])
const historialActualizaciones = ref([])
const motivoActualizacion = ref('')

const periodoNuevo = ref({
  anio: new Date().getFullYear(),
  mes: new Date().getMonth() + 1
})

const meses = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
]

const buscarPagos = async () => {
  if (tipoBusqueda.value === 'recibo' && !busqueda.value.recibo) {
    return showToast('Ingrese un número de recibo', 'warning')
  }
  if (tipoBusqueda.value === 'contrato' && !busqueda.value.contrato) {
    return showToast('Ingrese un número de contrato', 'warning')
  }
  if (tipoBusqueda.value === 'fecha' && !busqueda.value.fechaDesde) {
    return showToast('Seleccione una fecha de inicio', 'warning')
  }

  cargando.value = true
  try {
    const params = {
      p_tipo_busqueda: tipoBusqueda.value,
      p_recibo: busqueda.value.recibo || null,
      p_contrato: busqueda.value.contrato || null,
      p_fecha_desde: busqueda.value.fechaDesde || null,
      p_fecha_hasta: busqueda.value.fechaHasta
    }
    const response = await execute('SP_ASEO_PAGOS_BUSCAR', 'aseo_contratado', params)
    pagosEncontrados.value = response || []
    pagosSeleccionados.value = []
    showToast(`${pagosEncontrados.value.length} pago(s) encontrado(s)`, 'success')
  } catch (error) {
    handleError(error, 'Error al buscar pagos')
  } finally {
    cargando.value = false
  }
}

const seleccionarTodos = () => {
  pagosSeleccionados.value = pagosEncontrados.value.map(p => p.control_pago)
}

const limpiarSeleccion = () => {
  pagosSeleccionados.value = []
  seleccionarTodo.value = false
}

const toggleSeleccionTodos = () => {
  if (seleccionarTodo.value) {
    seleccionarTodos()
  } else {
    limpiarSeleccion()
  }
}

const validarActualizacion = () => {
  if (pagosSeleccionados.value.length === 0) return false
  if (!motivoActualizacion.value.trim()) return false
  if (tipoActualizacion.value === 'periodo_fijo') {
    return periodoNuevo.value.anio > 0 && periodoNuevo.value.mes > 0
  }
  return true
}

const confirmarActualizacion = async () => {
  const result = await Swal.fire({
    title: '¿Actualizar Periodos?',
    html: `Se actualizarán <strong>${pagosSeleccionados.value.length}</strong> pago(s).<br>
           Esta operación no se puede deshacer.`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#ffc107',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  cargando.value = true
  try {
    const params = {
      p_pagos: pagosSeleccionados.value.join(','),
      p_tipo_actualizacion: tipoActualizacion.value,
      p_periodo_anio: periodoNuevo.value.anio,
      p_periodo_mes: periodoNuevo.value.mes,
      p_criterio_calculo: criterioCalculo.value,
      p_motivo: motivoActualizacion.value
    }
    await execute('SP_ASEO_PAGOS_ACTUALIZAR_PERIODOS', 'aseo_contratado', params)

    await Swal.fire('¡Actualizado!', 'Los periodos han sido actualizados correctamente', 'success')

    // Recargar búsqueda y limpiar
    await buscarPagos()
    limpiarSeleccion()
    motivoActualizacion.value = ''
    await cargarHistorial()
  } catch (error) {
    handleError(error, 'Error al actualizar periodos')
  } finally {
    cargando.value = false
  }
}

const cancelarActualizacion = () => {
  limpiarSeleccion()
  motivoActualizacion.value = ''
}

const cargarHistorial = async () => {
  try {
    const response = await execute('SP_ASEO_PAGOS_HISTORIAL_ACTUALIZACIONES', 'aseo_contratado', {
      p_limit: 10
    })
    historialActualizaciones.value = response || []
  } catch (error) {
    console.error('Error al cargar historial:', error)
  }
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2 }).format(value || 0)
}

const formatFecha = (fecha) => {
  return fecha ? new Date(fecha).toLocaleDateString('es-MX') : 'N/A'
}
</script>

