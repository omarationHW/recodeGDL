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
    </div>

    <!-- Paso 1: Búsqueda de Pagos -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5><font-awesome-icon icon="search" class="me-2" />Paso 1: Búsqueda de Pagos</h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="form-label">Tipo de Búsqueda</label>
            <select class="form-control" v-model="tipoBusqueda">
              <option value="recibo">Por Número de Recibo</option>
              <option value="contrato">Por Contrato</option>
              <option value="fecha">Por Rango de Fechas</option>
            </select>
          </div>

          <!-- Búsqueda por Recibo -->
          <div class="form-group" v-if="tipoBusqueda === 'recibo'">
            <label class="form-label">Número de Recibo</label>
            <input
              type="text"
              class="form-control"
              v-model="busqueda.recibo"
              @keyup.enter="buscarPagos"
              placeholder="Ej: 12345"
            />
          </div>

          <!-- Búsqueda por Contrato -->
          <div class="form-group" v-if="tipoBusqueda === 'contrato'">
            <label class="form-label">Número de Contrato</label>
            <input
              type="text"
              class="form-control"
              v-model="busqueda.contrato"
              @keyup.enter="buscarPagos"
              placeholder="Ej: 001-2024"
            />
          </div>

          <!-- Búsqueda por Fecha -->
          <div class="form-group" v-if="tipoBusqueda === 'fecha'">
            <label class="form-label">Fecha Desde</label>
            <input type="date" class="form-control" v-model="busqueda.fechaDesde" />
          </div>
          <div class="form-group" v-if="tipoBusqueda === 'fecha'">
            <label class="form-label">Fecha Hasta</label>
            <input type="date" class="form-control" v-model="busqueda.fechaHasta" />
          </div>

          <div class="form-group" style="align-self: flex-end;">
            <button class="btn-municipal-primary" @click="buscarPagos">
              <font-awesome-icon icon="search" /> Buscar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla de Pagos Encontrados -->
    <div v-if="pagosEncontrados.length > 0" class="municipal-card">
      <div class="municipal-card-header d-flex justify-content-between align-items-center">
        <h5><font-awesome-icon icon="list" class="me-2" />Pagos Encontrados ({{ pagosEncontrados.length }})</h5>
        <div class="button-group">
          <button class="btn-municipal-success btn-sm" @click="seleccionarTodos">
            <font-awesome-icon icon="check-double" /> Todos
          </button>
          <button class="btn-municipal-secondary btn-sm" @click="limpiarSeleccion">
            <font-awesome-icon icon="eraser" /> Limpiar
          </button>
        </div>
      </div>
      <div class="municipal-card-body">
        <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
          <table class="municipal-table">
            <thead>
              <tr>
                <th style="width: 40px;">
                  <input
                    type="checkbox"
                    v-model="seleccionarTodo"
                    @change="toggleSeleccionTodos"
                  />
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
              <tr
                v-for="pago in pagosEncontrados"
                :key="pago.control_pago"
                :class="{ 'table-row-selected': pagosSeleccionados.includes(pago.control_pago) }"
              >
                <td>
                  <input
                    type="checkbox"
                    :value="pago.control_pago"
                    v-model="pagosSeleccionados"
                  />
                </td>
                <td>{{ pago.num_recibo }}</td>
                <td>{{ pago.num_contrato }}</td>
                <td>{{ pago.contribuyente }}</td>
                <td>{{ formatFecha(pago.fecha_pago) }}</td>
                <td>
                  <span class="badge badge-info">
                    {{ formatPeriodo(pago.periodo) }}
                  </span>
                </td>
                <td class="text-end font-weight-bold">${{ formatCurrency(pago.monto) }}</td>
                <td>{{ pago.forma_pago }}</td>
                <td>
                  <span class="badge" :class="pago.status === 'A' ? 'badge-success' : 'badge-danger'">
                    {{ pago.status === 'A' ? 'Activo' : 'Cancelado' }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Estado sin resultados -->
    <div v-else-if="busquedaRealizada" class="municipal-card">
      <div class="municipal-card-body">
        <div class="empty-state">
          <div class="empty-state-icon">
            <font-awesome-icon icon="receipt" />
          </div>
          <h4 class="empty-state-title">No se encontraron pagos</h4>
          <p class="empty-state-description">
            No hay pagos que coincidan con los criterios de búsqueda especificados.
          </p>
          <div class="empty-state-suggestions">
            <p><strong>Sugerencias:</strong></p>
            <ul>
              <li>Verifique el número de recibo o contrato</li>
              <li>Intente ampliar el rango de fechas</li>
              <li>Cambie el tipo de búsqueda</li>
            </ul>
          </div>
          <button class="btn-municipal-secondary mt-3" @click="limpiarBusqueda">
            <font-awesome-icon icon="eraser" /> Limpiar Búsqueda
          </button>
        </div>
      </div>
    </div>

    <!-- Estado inicial -->
    <div v-else-if="!busquedaRealizada" class="municipal-card">
      <div class="municipal-card-body">
        <div class="empty-state initial-state">
          <div class="empty-state-icon pulse">
            <font-awesome-icon icon="search-dollar" />
          </div>
          <h4 class="empty-state-title">Busque pagos para actualizar</h4>
          <p class="empty-state-description">
            Utilice los filtros anteriores para buscar los pagos a los que desea
            actualizar el periodo asociado.
          </p>
          <div class="empty-state-steps">
            <div class="step">
              <div class="step-number">1</div>
              <div class="step-text">Seleccione el tipo de búsqueda</div>
            </div>
            <div class="step">
              <div class="step-number">2</div>
              <div class="step-text">Ingrese los criterios</div>
            </div>
            <div class="step">
              <div class="step-number">3</div>
              <div class="step-text">Seleccione los pagos</div>
            </div>
            <div class="step">
              <div class="step-number">4</div>
              <div class="step-text">Actualice los periodos</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Paso 2: Actualización de Periodos -->
    <div v-if="pagosSeleccionados.length > 0" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="calendar-alt" class="me-2" />
          Paso 2: Actualización de Periodos ({{ pagosSeleccionados.length }} seleccionados)
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="municipal-alert municipal-alert-warning mb-3">
          <font-awesome-icon icon="exclamation-triangle" class="me-2" />
          <strong>Atención:</strong> Esta operación actualizará los periodos de los pagos seleccionados.
          Verifique cuidadosamente antes de proceder.
        </div>

        <div class="form-row">
          <div class="form-group">
            <label class="form-label">Tipo de Actualización</label>
            <select class="form-control" v-model="tipoActualizacion">
              <option value="periodo_fijo">Periodo Fijo</option>
              <option value="periodo_calculado">Calcular Automáticamente</option>
            </select>
          </div>

          <!-- Periodo Fijo -->
          <div class="form-group" v-if="tipoActualizacion === 'periodo_fijo'">
            <label class="form-label required">Año</label>
            <input
              type="number"
              class="form-control"
              v-model.number="periodoNuevo.anio"
              min="2000"
              :max="new Date().getFullYear() + 1"
            />
          </div>
          <div class="form-group" v-if="tipoActualizacion === 'periodo_fijo'">
            <label class="form-label required">Mes</label>
            <select class="form-control" v-model="periodoNuevo.mes">
              <option v-for="(mes, index) in meses" :key="index" :value="index + 1">
                {{ mes }}
              </option>
            </select>
          </div>

          <!-- Criterio de Cálculo -->
          <div class="form-group" v-if="tipoActualizacion === 'periodo_calculado'">
            <label class="form-label">Criterio de Cálculo</label>
            <select class="form-control" v-model="criterioCalculo">
              <option value="fecha_pago">Basado en Fecha de Pago</option>
              <option value="ultimo_periodo">Último Periodo Pagado</option>
              <option value="fecha_vencimiento">Fecha de Vencimiento</option>
            </select>
          </div>
        </div>

        <div v-if="tipoActualizacion === 'periodo_fijo'" class="municipal-alert municipal-alert-info mb-3">
          <strong>Periodo a asignar:</strong> {{ meses[periodoNuevo.mes - 1] }} {{ periodoNuevo.anio }}
          <span class="badge badge-primary ms-2">{{ periodoNuevo.anio }}{{ String(periodoNuevo.mes).padStart(2, '0') }}</span>
        </div>

        <div class="form-row">
          <div class="form-group" style="flex: 1;">
            <label class="form-label required">Motivo de la Actualización</label>
            <textarea
              class="form-control"
              v-model="motivoActualizacion"
              rows="3"
              placeholder="Describa el motivo de esta actualización..."
            ></textarea>
          </div>
        </div>

        <div class="form-actions">
          <button class="btn-municipal-secondary" @click="cancelarActualizacion">
            <font-awesome-icon icon="times" /> Cancelar
          </button>
          <button
            class="btn-municipal-warning"
            @click="confirmarActualizacion"
            :disabled="!validarActualizacion()"
          >
            <font-awesome-icon icon="save" /> Actualizar Periodos
          </button>
        </div>
      </div>
    </div>

    <!-- Resultado de la operación -->
    <div v-if="resultado" class="municipal-card">
      <div class="municipal-card-header" :class="resultado.success ? 'bg-success text-white' : 'bg-danger text-white'">
        <h5>
          <font-awesome-icon :icon="resultado.success ? 'check-circle' : 'exclamation-circle'" class="me-2" />
          Resultado de la Operación
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="row text-center">
          <div class="col-md-4">
            <div class="stat-box">
              <div class="stat-number">{{ resultado.pagos_procesados }}</div>
              <div class="stat-label">Pagos Procesados</div>
            </div>
          </div>
          <div class="col-md-4">
            <div class="stat-box bg-success text-white">
              <div class="stat-number">{{ resultado.actualizaciones_exitosas }}</div>
              <div class="stat-label">Actualizados</div>
            </div>
          </div>
          <div class="col-md-4">
            <div class="stat-box bg-danger text-white">
              <div class="stat-number">{{ resultado.errores }}</div>
              <div class="stat-label">Errores</div>
            </div>
          </div>
        </div>
        <p class="text-center mt-3">{{ resultado.message }}</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

const BASE_DB = 'aseo_contratado'
const SCHEMA = 'publico'

const { execute } = useApi()
const { showToast, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const tipoBusqueda = ref('recibo')
const tipoActualizacion = ref('periodo_fijo')
const criterioCalculo = ref('fecha_pago')
const seleccionarTodo = ref(false)
const busquedaRealizada = ref(false)
const resultado = ref(null)

const busqueda = ref({
  recibo: '',
  contrato: '',
  fechaDesde: '',
  fechaHasta: new Date().toISOString().split('T')[0]
})

const pagosEncontrados = ref([])
const pagosSeleccionados = ref([])
const motivoActualizacion = ref('')

const periodoNuevo = ref({
  anio: new Date().getFullYear(),
  mes: new Date().getMonth() + 1
})

const meses = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
]

// Métodos
const buscarPagos = async () => {
  // Validaciones
  if (tipoBusqueda.value === 'recibo' && !busqueda.value.recibo) {
    showToast('Ingrese un número de recibo', 'warning')
    return
  }
  if (tipoBusqueda.value === 'contrato' && !busqueda.value.contrato) {
    showToast('Ingrese un número de contrato', 'warning')
    return
  }
  if (tipoBusqueda.value === 'fecha' && !busqueda.value.fechaDesde) {
    showToast('Seleccione una fecha de inicio', 'warning')
    return
  }

  showLoading()
  busquedaRealizada.value = true
  resultado.value = null

  try {
    const params = []

    if (tipoBusqueda.value === 'recibo' && busqueda.value.recibo) {
      params.push({ nombre: 'p_num_recibo', valor: busqueda.value.recibo, tipo: 'string' })
    }
    if (tipoBusqueda.value === 'contrato' && busqueda.value.contrato) {
      params.push({ nombre: 'p_num_contrato', valor: busqueda.value.contrato, tipo: 'string' })
    }
    if (tipoBusqueda.value === 'fecha') {
      if (busqueda.value.fechaDesde) {
        params.push({ nombre: 'p_fecha_desde', valor: busqueda.value.fechaDesde, tipo: 'string' })
      }
      if (busqueda.value.fechaHasta) {
        params.push({ nombre: 'p_fecha_hasta', valor: busqueda.value.fechaHasta, tipo: 'string' })
      }
    }

    const response = await execute('sp_aseo_pagos_list', BASE_DB, params, '', null, SCHEMA)
    pagosEncontrados.value = response?.result || []
    pagosSeleccionados.value = []
    seleccionarTodo.value = false

    showToast(`${pagosEncontrados.value.length} pago(s, 'success') encontrado(s)`)
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al buscar pagos')
    pagosEncontrados.value = []
  } finally {
    hideLoading()
  }
}

const seleccionarTodos = () => {
  pagosSeleccionados.value = pagosEncontrados.value.map(p => p.control_pago)
  seleccionarTodo.value = true
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

const limpiarBusqueda = () => {
  busqueda.value = {
    recibo: '',
    contrato: '',
    fechaDesde: '',
    fechaHasta: new Date().toISOString().split('T')[0]
  }
  pagosEncontrados.value = []
  pagosSeleccionados.value = []
  busquedaRealizada.value = false
  resultado.value = null
}

const validarActualizacion = () => {
  if (pagosSeleccionados.value.length === 0) return false
  if (!motivoActualizacion.value.trim()) return false
  if (tipoActualizacion.value === 'periodo_fijo') {
    return periodoNuevo.value.anio >= 2000 && periodoNuevo.value.mes >= 1 && periodoNuevo.value.mes <= 12
  }
  return true
}

const confirmarActualizacion = async () => {
  const periodoFormateado = tipoActualizacion.value === 'periodo_fijo'
    ? `${meses[periodoNuevo.value.mes - 1]} ${periodoNuevo.value.anio}`
    : 'Calculado automáticamente'

  const confirmResult = await Swal.fire({
    title: '¿Actualizar Periodos?',
    html: `Se actualizarán <strong>${pagosSeleccionados.value.length}</strong> pago(s).<br>
           Nuevo periodo: <strong>${periodoFormateado}</strong><br><br>
           <small class="text-muted">Esta operación no se puede deshacer.</small>`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#ffc107',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) return

  showLoading()

  let actualizados = 0
  let errores = 0

  try {
    const periodoNuevoStr = `${periodoNuevo.value.anio}${String(periodoNuevo.value.mes).padStart(2, '0')}`

    for (const controlPago of pagosSeleccionados.value) {
      try {
        const params = [
          { nombre: 'p_control_pago', valor: controlPago, tipo: 'integer' },
          { nombre: 'p_periodo', valor: periodoNuevoStr, tipo: 'string' }
        ]

        const response = await execute('sp_aseo_pagos_update', BASE_DB, params, '', null, SCHEMA)

        if (response?.result?.[0]?.success === false) {
          errores++
        } else {
          actualizados++
        }
      } catch {
        errores++
      }
    }

    hideLoading()

    resultado.value = {
      success: errores === 0,
      message: errores === 0
        ? 'Todos los periodos fueron actualizados correctamente'
        : `Completado con ${errores} error(es)`,
      pagos_procesados: pagosSeleccionados.value.length,
      actualizaciones_exitosas: actualizados,
      errores: errores
    }

    await Swal.fire(
      '¡Proceso completado!',
      `Actualizados: ${actualizados}, Errores: ${errores}`,
      errores === 0 ? 'success' : 'warning'
    )

    // Refrescar lista
    await buscarPagos()
    cancelarActualizacion()

  } catch (error) {
    hideLoading()
    hideLoading()
    handleApiError(error, 'Error al actualizar periodos')
  }
}

const cancelarActualizacion = () => {
  limpiarSeleccion()
  motivoActualizacion.value = ''
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2 }).format(value || 0)
}

const formatFecha = (fecha) => {
  if (!fecha) return 'N/A'
  return new Date(fecha).toLocaleDateString('es-MX')
}

const formatPeriodo = (periodo) => {
  if (!periodo || periodo.length !== 6) return periodo || 'Sin asignar'
  const anio = periodo.substring(0, 4)
  const mes = periodo.substring(4, 6)
  const mesNombre = meses[parseInt(mes) - 1]
  return `${mesNombre} ${anio}`
}

onMounted(() => {
  // Inicialización si es necesaria
})
</script>

