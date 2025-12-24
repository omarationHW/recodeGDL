<template>
  <div class="module-view">
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="calendar-days" />
      </div>
      <div class="module-view-info">
        <h1>Actualización de Periodos de Contratos</h1>
        <p>Aseo Contratado - Modificación masiva de periodos de facturación</p>
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
        <h5>Paso 1: Selección de Contratos</h5>
      </div>
      <div class="municipal-card-body">
        <div class="row mb-3">
          <div class="col-md-3">
            <label class="municipal-form-label">Empresa</label>
            <select class="municipal-form-control" v-model="filtros.empresa">
              <option value="">Todas</option>
              <option v-for="emp in empresas" :key="emp.num_empresa" :value="emp.num_empresa">
                {{ emp.nombre_empresa }}
              </option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">Tipo de Aseo</label>
            <select class="municipal-form-control" v-model="filtros.tipoAseo">
              <option value="">Todos</option>
              <option value="D">Doméstico</option>
              <option value="C">Comercial</option>
              <option value="I">Industrial</option>
              <option value="S">Servicios</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">Zona</label>
            <select class="municipal-form-control" v-model="filtros.zona">
              <option value="">Todas</option>
              <option v-for="z in zonas" :key="z.ctrol_zona" :value="z.zona">
                Zona {{ z.zona }}
              </option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Periodo Actual</label>
            <input type="text" class="municipal-form-control" v-model="filtros.periodoActual"
              placeholder="YYYYMM (ej: 202401)" />
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">&nbsp;</label>
            <button class="btn-municipal-info w-100" @click="buscarContratos" :disabled="cargando">
              <font-awesome-icon icon="search" /> Buscar
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="contratos.length > 0">
      <div class="municipal-card shadow-sm mb-4">
        <div class="municipal-card-header bg-light d-flex justify-content-between">
          <h6 class="mb-0">Contratos Encontrados ({{ contratos.length }})</h6>
          <div>
            <button class="btn btn-sm btn-success" @click="seleccionarTodos">
              <font-awesome-icon icon="check-double" /> Todos
            </button>
            <button class="btn btn-sm btn-secondary ms-2" @click="limpiarSeleccion">
              <font-awesome-icon icon="eraser" /> Limpiar
            </button>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
            <table class="municipal-table">
              <thead class="table-light" style="position: sticky; top: 0;">
                <tr>
                  <th style="width: 40px;">
                    <input type="checkbox" class="form-check-input" v-model="seleccionarTodo"
                      @change="toggleSeleccionTodos" />
                  </th>
                  <th>Contrato</th>
                  <th>Contribuyente</th>
                  <th>Tipo</th>
                  <th>Zona</th>
                  <th>Periodo Actual</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="contrato in contratos" :key="contrato.control_contrato"
                    :class="{ 'table-warning': contratosSeleccionados.includes(contrato.control_contrato) }">
                  <td>
                    <input type="checkbox" class="form-check-input"
                      :value="contrato.control_contrato" v-model="contratosSeleccionados" />
                  </td>
                  <td>{{ contrato.num_contrato }}</td>
                  <td>{{ contrato.contribuyente }}</td>
                  <td>{{ formatTipoAseo(contrato.tipo_aseo) }}</td>
                  <td>{{ contrato.zona }}</td>
                  <td>{{ contrato.periodo_actual || 'Sin asignar' }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div v-if="contratosSeleccionados.length > 0" class="municipal-card">
        <div class="municipal-card-header">
        <h5>Paso 2: Actualización de Periodo ({{ contratosSeleccionados.length }} seleccionados)</h5>
      </div>
        <div class="municipal-card-body">
          <div class="alert alert-warning">
            <font-awesome-icon icon="exclamation-triangle" class="me-2" />
            Esta operación actualizará el periodo de facturación de los contratos seleccionados.
          </div>

          <div class="row mb-3">
            <div class="col-md-3">
              <label class="municipal-form-label">Nuevo Periodo *</label>
              <input type="text" class="municipal-form-control" v-model="nuevoPeriodo"
                placeholder="YYYYMM (ej: 202402)" maxlength="6" />
              <small class="text-muted">Formato: Año (4 dígitos) + Mes (2 dígitos)</small>
            </div>
            <div class="col-md-3">
              <label class="municipal-form-label">O Seleccionar Fecha</label>
              <input type="month" class="municipal-form-control" @change="actualizarDesdeFecha" />
            </div>
            <div class="col-md-6">
              <label class="municipal-form-label">Motivo de la Actualización *</label>
              <input type="text" class="municipal-form-control" v-model="motivo"
                placeholder="Ej: Ajuste de periodo por cambio de ciclo de facturación" />
            </div>
          </div>

          <div v-if="nuevoPeriodo" class="alert alert-info">
            <strong>Periodo a asignar:</strong>
            {{ formatPeriodo(nuevoPeriodo) }}
          </div>

          <div class="d-flex justify-content-end">
            <button class="btn-municipal-secondary me-2" @click="cancelar">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
            <button class="btn-municipal-info" @click="actualizarPeriodos"
              :disabled="!validarActualizacion()">
              <font-awesome-icon icon="save" /> Actualizar Periodos
            </button>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Actualización de Periodos">
      <h6>Descripción</h6>
      <p>Permite actualizar masivamente el periodo de facturación de múltiples contratos.</p>
      <h6>Formato de Periodo</h6>
      <p>El periodo debe ingresarse en formato <strong>YYYYMM</strong>:</p>
      <ul>
        <li>YYYY = Año (4 dígitos)</li>
        <li>MM = Mes (2 dígitos, 01-12)</li>
        <li>Ejemplo: 202401 = Enero 2024</li>
      </ul>
      <h6>Casos de Uso</h6>
      <ul>
        <li>Ajuste de ciclo de facturación</li>
        <li>Corrección de periodos incorrectos</li>
        <li>Sincronización masiva de periodos</li>
      </ul>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
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
const contratos = ref([])
const empresas = ref([])
const zonas = ref([])
const contratosSeleccionados = ref([])
const seleccionarTodo = ref(false)
const nuevoPeriodo = ref('')
const motivo = ref('')

const filtros = ref({
  empresa: '',
  tipoAseo: '',
  zona: '',
  periodoActual: ''
})

const buscarContratos = async () => {
  cargando.value = true
  try {
    const params = {
      p_empresa: filtros.value.empresa || null,
      p_tipo_aseo: filtros.value.tipoAseo || null,
      p_zona: filtros.value.zona || null,
      p_periodo_actual: filtros.value.periodoActual || null
    }
    const response = await execute('SP_ASEO_CONTRATOS_PARA_UPD_PERIODO', 'aseo_contratado', params)
    contratos.value = response || []
    contratosSeleccionados.value = []
    showToast(`${contratos.value.length} contrato(s) encontrado(s)`, 'success')
  } catch (error) {
    handleError(error, 'Error al buscar contratos')
  } finally {
    cargando.value = false
  }
}

const seleccionarTodos = () => {
  contratosSeleccionados.value = contratos.value.map(c => c.control_contrato)
  seleccionarTodo.value = true
}

const limpiarSeleccion = () => {
  contratosSeleccionados.value = []
  seleccionarTodo.value = false
}

const toggleSeleccionTodos = () => {
  if (seleccionarTodo.value) {
    seleccionarTodos()
  } else {
    limpiarSeleccion()
  }
}

const actualizarDesdeFecha = (event) => {
  const fecha = event.target.value
  if (fecha) {
    const [anio, mes] = fecha.split('-')
    nuevoPeriodo.value = `${anio}${mes}`
  }
}

const validarActualizacion = () => {
  if (contratosSeleccionados.value.length === 0) return false
  if (!nuevoPeriodo.value || nuevoPeriodo.value.length !== 6) return false
  if (!motivo.value.trim()) return false
  const anio = parseInt(nuevoPeriodo.value.substring(0, 4))
  const mes = parseInt(nuevoPeriodo.value.substring(4, 6))
  return anio >= 2000 && anio <= 2099 && mes >= 1 && mes <= 12
}

const formatPeriodo = (periodo) => {
  if (!periodo || periodo.length !== 6) return periodo
  const anio = periodo.substring(0, 4)
  const mes = periodo.substring(4, 6)
  const meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
  const mesNombre = meses[parseInt(mes) - 1]
  return `${mesNombre} ${anio}`
}

const actualizarPeriodos = async () => {
  const result = await Swal.fire({
    title: '¿Actualizar Periodos?',
    html: `Se actualizarán <strong>${contratosSeleccionados.value.length}</strong> contrato(s)<br>
           Nuevo periodo: <strong>${formatPeriodo(nuevoPeriodo.value)}</strong>`,
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
      p_contratos: contratosSeleccionados.value.join(','),
      p_nuevo_periodo: nuevoPeriodo.value,
      p_motivo: motivo.value
    }
    await execute('SP_ASEO_ACTUALIZAR_PERIODOS_CONTRATOS', 'aseo_contratado', params)

    await Swal.fire('¡Actualizado!', 'Los periodos han sido actualizados correctamente', 'success')

    await buscarContratos()
    cancelar()
  } catch (error) {
    handleError(error, 'Error al actualizar periodos')
  } finally {
    cargando.value = false
  }
}

const cancelar = () => {
  contratosSeleccionados.value = []
  nuevoPeriodo.value = ''
  motivo.value = ''
  seleccionarTodo.value = false
}

const formatTipoAseo = (tipo) => {
  const tipos = { 'D': 'Dom', 'C': 'Com', 'I': 'Ind', 'S': 'Ser' }
  return tipos[tipo] || tipo
}

onMounted(async () => {
  try {
    const [respEmpresas, respZonas] = await Promise.all([
      execute('SP_ASEO_EMPRESAS_LIST', 'aseo_contratado', {}),
      execute('SP_ASEO_ZONAS_LIST', 'aseo_contratado', {})
    ])
    empresas.value = respEmpresas || []
    zonas.value = respZonas || []
  } catch (error) {
    console.error('Error al cargar catálogos:', error)
  }
})
</script>
