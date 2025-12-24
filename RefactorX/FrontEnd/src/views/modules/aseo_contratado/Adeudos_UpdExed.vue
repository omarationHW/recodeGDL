<template>
  <div class="module-view">
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="shield-halved" />
      </div>
      <div class="module-view-info">
        <h1>Actualización de Adeudos Exentos</h1>
        <p>Aseo Contratado - Gestión de exenciones y descuentos especiales en adeudos</p>
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
        <h5>Búsqueda de Contrato</h5>
      </div>
      <div class="municipal-card-body">
        <div class="row">
          <div class="col-md-4">
            <input type="text" class="municipal-form-control" v-model="busqueda" @keyup.enter="buscarContrato"
              placeholder="Número de contrato o cuenta predial" />
          </div>
          <div class="col-md-2">
            <button class="btn-municipal-primary w-100" @click="buscarContrato" :disabled="cargando">
              <font-awesome-icon icon="search" /> Buscar
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="contratoSeleccionado">
      <div class="municipal-card shadow-sm mb-4">
        <div class="municipal-card-header">
        <h5>Información del Contrato</h5>
      </div>
        <div class="municipal-card-body">
          <div class="row">
            <div class="col-md-3">
              <strong>Contrato:</strong> {{ contratoSeleccionado.num_contrato }}<br>
              <strong>Status:</strong>
              <span class="badge" :class="contratoSeleccionado.status === 'A' ? 'bg-success' : 'bg-danger'">
                {{ contratoSeleccionado.status === 'A' ? 'Activo' : 'Inactivo' }}
              </span>
            </div>
            <div class="col-md-3">
              <strong>Contribuyente:</strong> {{ contratoSeleccionado.contribuyente }}<br>
              <strong>RFC:</strong> {{ contratoSeleccionado.rfc || 'N/A' }}
            </div>
            <div class="col-md-3">
              <strong>Tipo:</strong> {{ formatTipoAseo(contratoSeleccionado.tipo_aseo) }}<br>
              <strong>Cuota:</strong> ${{ formatCurrency(contratoSeleccionado.cuota_mensual) }}
            </div>
            <div class="col-md-3">
              <strong>Exención Actual:</strong>
              <span class="badge" :class="contratoSeleccionado.exencion ? 'bg-success' : 'bg-secondary'">
                {{ contratoSeleccionado.exencion ? 'Con Exención' : 'Sin Exención' }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card shadow-sm mb-4">
        <div class="municipal-card-header bg-light d-flex justify-content-between">
          <h6 class="mb-0">Adeudos del Contrato ({{ adeudos.length }})</h6>
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
                    <input type="checkbox" class="form-check-input" @change="toggleSeleccionTodos" />
                  </th>
                  <th>Folio</th>
                  <th>Periodo</th>
                  <th>Vencimiento</th>
                  <th class="text-end">Cuota Base</th>
                  <th class="text-end">Recargos</th>
                  <th class="text-end">Total</th>
                  <th>Exención Actual</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="adeudo in adeudos" :key="adeudo.folio"
                    :class="{ 'table-success': adeudosSeleccionados.includes(adeudo.folio) }">
                  <td>
                    <input type="checkbox" class="form-check-input"
                      :value="adeudo.folio" v-model="adeudosSeleccionados"
                      :disabled="adeudo.status !== 'P'" />
                  </td>
                  <td>{{ adeudo.folio }}</td>
                  <td>{{ adeudo.periodo }}</td>
                  <td>{{ formatFecha(adeudo.fecha_vencimiento) }}</td>
                  <td class="text-end">${{ formatCurrency(adeudo.cuota_base) }}</td>
                  <td class="text-end">${{ formatCurrency(adeudo.recargos) }}</td>
                  <td class="text-end"><strong>${{ formatCurrency(adeudo.total_periodo) }}</strong></td>
                  <td>
                    <span v-if="adeudo.porcentaje_exencion > 0" class="badge badge-success">
                      {{ adeudo.porcentaje_exencion }}%
                    </span>
                    <span v-else class="badge badge-secondary">Sin exención</span>
                  </td>
                  <td>
                    <span class="badge" :class="adeudo.status === 'P' ? 'bg-warning' : 'bg-success'">
                      {{ adeudo.status === 'P' ? 'Pendiente' : 'Pagado' }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div v-if="adeudosSeleccionados.length > 0" class="municipal-card">
        <div class="municipal-card-header">
        <h5>Configuración de Exención ({{ adeudosSeleccionados.length }} adeudos seleccionados)</h5>
        </div>
        <div class="municipal-card-body">
          <div class="alert alert-warning">
            <font-awesome-icon icon="exclamation-triangle" class="me-2" />
            <strong>Importante:</strong> Las exenciones deben contar con la autorización correspondiente.
          </div>

          <div class="row mb-3">
            <div class="col-md-3">
              <label class="municipal-form-label">Tipo de Exención</label>
              <select class="municipal-form-control" v-model="exencion.tipo">
                <option value="">Seleccione...</option>
                <option value="TOTAL">Exención Total (100%)</option>
                <option value="PARCIAL">Exención Parcial</option>
                <option value="TERCERA_EDAD">Adulto Mayor</option>
                <option value="DISCAPACIDAD">Persona con Discapacidad</option>
                <option value="JUBILADO">Jubilado/Pensionado</option>
                <option value="VIUDA">Viuda(o)</option>
                <option value="OTRO">Otro Motivo</option>
              </select>
            </div>
            <div class="col-md-2" v-if="exencion.tipo === 'PARCIAL' || exencion.tipo === 'OTRO'">
              <label class="municipal-form-label">Porcentaje (%)</label>
              <input type="number" class="municipal-form-control" v-model.number="exencion.porcentaje"
                min="1" max="100" />
            </div>
            <div class="col-md-2" v-else-if="exencion.tipo">
              <label class="municipal-form-label">Porcentaje (%)</label>
              <input type="number" class="municipal-form-control" :value="obtenerPorcentajePredefinido()"
                disabled />
            </div>
            <div class="col-md-3">
              <label class="municipal-form-label">Vigencia Desde</label>
              <input type="date" class="municipal-form-control" v-model="exencion.vigenciaDesde" />
            </div>
            <div class="col-md-3">
              <label class="municipal-form-label">Vigencia Hasta</label>
              <input type="date" class="municipal-form-control" v-model="exencion.vigenciaHasta" />
            </div>
          </div>

          <div class="row mb-3">
            <div class="col-md-4">
              <label class="municipal-form-label">Documento de Autorización</label>
              <input type="text" class="municipal-form-control" v-model="exencion.documentoAutorizacion"
                placeholder="Número de oficio o documento" />
            </div>
            <div class="col-md-4">
              <label class="municipal-form-label">Autorizado Por</label>
              <input type="text" class="municipal-form-control" v-model="exencion.autorizadoPor"
                placeholder="Nombre del funcionario" />
            </div>
            <div class="col-md-4">
              <label class="municipal-form-label">Fecha de Autorización</label>
              <input type="date" class="municipal-form-control" v-model="exencion.fechaAutorizacion" />
            </div>
          </div>

          <div class="row mb-3">
            <div class="col-md-12">
              <label class="municipal-form-label">Observaciones</label>
              <textarea class="municipal-form-control" v-model="exencion.observaciones" rows="3"
                placeholder="Fundamento legal o motivo de la exención..."></textarea>
            </div>
          </div>

          <div v-if="calcularTotales()" class="alert alert-info">
            <div class="row">
              <div class="col-md-3">
                <strong>Total Original:</strong> ${{ formatCurrency(calcularTotales().original) }}
              </div>
              <div class="col-md-3">
                <strong>Descuento:</strong> ${{ formatCurrency(calcularTotales().descuento) }}
              </div>
              <div class="col-md-3">
                <strong>Total con Exención:</strong> ${{ formatCurrency(calcularTotales().final) }}
              </div>
              <div class="col-md-3">
                <strong>Ahorro:</strong>
                <span class="badge bg-success fs-6">
                  {{ calcularTotales().porcentaje }}%
                </span>
              </div>
            </div>
          </div>

          <div class="d-flex justify-content-end">
            <button class="btn-municipal-secondary me-2" @click="cancelarExencion">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
            <button class="btn-municipal-primary" @click="aplicarExencion"
              :disabled="!validarExencion()">
              <font-awesome-icon icon="check" /> Aplicar Exención
            </button>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Actualización de Adeudos Exentos">
      <h6>Descripción</h6>
      <p>Permite aplicar, modificar o eliminar exenciones sobre adeudos pendientes de pago.</p>
      <h6>Tipos de Exención</h6>
      <ul>
        <li><strong>Exención Total:</strong> 100% de descuento</li>
        <li><strong>Adulto Mayor:</strong> Descuento según reglamento (típicamente 50%)</li>
        <li><strong>Persona con Discapacidad:</strong> Descuento especial (típicamente 50%)</li>
        <li><strong>Jubilado/Pensionado:</strong> Beneficio a pensionados (típicamente 25%)</li>
        <li><strong>Viuda(o):</strong> Apoyo especial (típicamente 25%)</li>
      </ul>
      <h6>Requisitos</h6>
      <ul>
        <li>Documento de autorización oficial</li>
        <li>Nombre del funcionario autorizante</li>
        <li>Fundamento legal o justificación</li>
        <li>Vigencia de la exención</li>
      </ul>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref } from 'vue'
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
const busqueda = ref('')
const contratoSeleccionado = ref(null)
const adeudos = ref([])
const adeudosSeleccionados = ref([])

const exencion = ref({
  tipo: '',
  porcentaje: 0,
  vigenciaDesde: '',
  vigenciaHasta: '',
  documentoAutorizacion: '',
  autorizadoPor: '',
  fechaAutorizacion: '',
  observaciones: ''
})

const buscarContrato = async () => {
  if (!busqueda.value) {
    return showToast('Ingrese un número de contrato', 'warning')
  }

  cargando.value = true
  try {
    const [respContrato] = await Promise.all([
      execute('SP_ASEO_CONTRATO_CONSULTAR', 'aseo_contratado', {
        p_num_contrato: busqueda.value
      })
    ])
    if (respContrato?.length > 0) {
      contratoSeleccionado.value = respContrato[0]
      const respAdeudos = await execute('SP_ASEO_ADEUDOS_POR_CONTRATO', 'aseo_contratado', {
        p_control_contrato: respContrato[0].control_contrato
      })
      adeudos.value = (respAdeudos || []).filter(a => a.status === 'P')
      adeudosSeleccionados.value = []
      showToast('Contrato encontrado', 'success')
    } else {
      showToast('Contrato no encontrado', 'error')
    }
  } catch (error) {
    handleError(error, 'Error al buscar contrato')
  } finally {
    cargando.value = false
  }
}

const seleccionarTodos = () => {
  adeudosSeleccionados.value = adeudos.value
    .filter(a => a.status === 'P')
    .map(a => a.folio)
}

const limpiarSeleccion = () => {
  adeudosSeleccionados.value = []
}

const toggleSeleccionTodos = (event) => {
  if (event.target.checked) {
    seleccionarTodos()
  } else {
    limpiarSeleccion()
  }
}

const obtenerPorcentajePredefinido = () => {
  const porcentajes = {
    'TOTAL': 100,
    'TERCERA_EDAD': 50,
    'DISCAPACIDAD': 50,
    'JUBILADO': 25,
    'VIUDA': 25
  }
  return porcentajes[exencion.value.tipo] || 0
}

const calcularTotales = () => {
  if (adeudosSeleccionados.value.length === 0) return null

  const adeudosACalcular = adeudos.value.filter(a =>
    adeudosSeleccionados.value.includes(a.folio)
  )

  const original = adeudosACalcular.reduce((sum, a) =>
    sum + parseFloat(a.total_periodo || 0), 0
  )

  let porcentaje = exencion.value.tipo === 'PARCIAL' || exencion.value.tipo === 'OTRO'
    ? exencion.value.porcentaje
    : obtenerPorcentajePredefinido()

  const descuento = original * (porcentaje / 100)
  const final = original - descuento

  return {
    original,
    descuento,
    final,
    porcentaje
  }
}

const validarExencion = () => {
  if (!exencion.value.tipo) return false
  if (!exencion.value.documentoAutorizacion) return false
  if (!exencion.value.autorizadoPor) return false
  if (!exencion.value.fechaAutorizacion) return false
  if ((exencion.value.tipo === 'PARCIAL' || exencion.value.tipo === 'OTRO')
      && exencion.value.porcentaje <= 0) return false
  return true
}

const aplicarExencion = async () => {
  const totales = calcularTotales()
  const porcentaje = exencion.value.tipo === 'PARCIAL' || exencion.value.tipo === 'OTRO'
    ? exencion.value.porcentaje
    : obtenerPorcentajePredefinido()

  const result = await Swal.fire({
    title: '¿Aplicar Exención?',
    html: `
      <p>Tipo: <strong>${exencion.value.tipo}</strong></p>
      <p>Porcentaje: <strong>${porcentaje}%</strong></p>
      <p>Adeudos: <strong>${adeudosSeleccionados.value.length}</strong></p>
      <p>Descuento Total: <strong>$${totales.descuento.toFixed(2)}</strong></p>
      <p class="text-warning">Esta operación requiere autorización oficial.</p>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#28a745',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, aplicar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  cargando.value = true
  try {
    const params = {
      p_control_contrato: contratoSeleccionado.value.control_contrato,
      p_adeudos: adeudosSeleccionados.value.join(','),
      p_tipo_exencion: exencion.value.tipo,
      p_porcentaje: porcentaje,
      p_vigencia_desde: exencion.value.vigenciaDesde,
      p_vigencia_hasta: exencion.value.vigenciaHasta,
      p_documento_autorizacion: exencion.value.documentoAutorizacion,
      p_autorizado_por: exencion.value.autorizadoPor,
      p_fecha_autorizacion: exencion.value.fechaAutorizacion,
      p_observaciones: exencion.value.observaciones
    }
    await execute('SP_ASEO_APLICAR_EXENCION', 'aseo_contratado', params)

    await Swal.fire('¡Exención Aplicada!', 'La exención ha sido aplicada correctamente', 'success')

    // Recargar adeudos
    await buscarContrato()
    cancelarExencion()
  } catch (error) {
    handleError(error, 'Error al aplicar exención')
  } finally {
    cargando.value = false
  }
}

const cancelarExencion = () => {
  limpiarSeleccion()
  exencion.value = {
    tipo: '',
    porcentaje: 0,
    vigenciaDesde: '',
    vigenciaHasta: '',
    documentoAutorizacion: '',
    autorizadoPor: '',
    fechaAutorizacion: '',
    observaciones: ''
  }
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2 }).format(value || 0)
}

const formatFecha = (fecha) => {
  return fecha ? new Date(fecha).toLocaleDateString('es-MX') : 'N/A'
}

const formatTipoAseo = (tipo) => {
  const tipos = { 'D': 'Doméstico', 'C': 'Comercial', 'I': 'Industrial', 'S': 'Servicios' }
  return tipos[tipo] || tipo
}
</script>
