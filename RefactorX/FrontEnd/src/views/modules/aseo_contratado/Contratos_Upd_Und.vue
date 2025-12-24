<template>
  <div class="module-view">
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="truck" />
      </div>
      <div class="module-view-info">
        <h1>Actualización de Unidades Recolectoras</h1>
        <p>Aseo Contratado - Reasignación de unidades de recolección a contratos</p>
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
        <h5>Paso 1: Búsqueda de Contratos</h5>
      </div>
      <div class="municipal-card-body">
        <div class="row mb-3">
          <div class="col-md-3">
            <label class="municipal-form-label">Zona</label>
            <select class="municipal-form-control" v-model="filtros.zona">
              <option value="">Todas</option>
              <option v-for="z in zonas" :key="z.ctrol_zona" :value="z.zona">
                Zona {{ z.zona }}
              </option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Unidad Actual</label>
            <select class="municipal-form-control" v-model="filtros.unidadActual">
              <option value="">Todas</option>
              <option v-for="u in unidades" :key="u.num_unidad" :value="u.num_unidad">
                {{ u.nombre_unidad }}
              </option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Tipo de Aseo</label>
            <select class="municipal-form-control" v-model="filtros.tipoAseo">
              <option value="">Todos</option>
              <option value="D">Doméstico</option>
              <option value="C">Comercial</option>
              <option value="I">Industrial</option>
              <option value="S">Servicios</option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">&nbsp;</label>
            <button class="btn-municipal-primary w-100" @click="buscarContratos" :disabled="cargando">
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
                  <th>Zona</th>
                  <th>Tipo</th>
                  <th>Unidad Actual</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="contrato in contratos" :key="contrato.control_contrato"
                    :class="{ 'table-primary': contratosSeleccionados.includes(contrato.control_contrato) }">
                  <td>
                    <input type="checkbox" class="form-check-input"
                      :value="contrato.control_contrato" v-model="contratosSeleccionados" />
                  </td>
                  <td>{{ contrato.num_contrato }}</td>
                  <td>{{ contrato.contribuyente }}</td>
                  <td>{{ contrato.zona }}</td>
                  <td>{{ formatTipoAseo(contrato.tipo_aseo) }}</td>
                  <td>{{ contrato.unidad_actual || 'Sin asignar' }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div v-if="contratosSeleccionados.length > 0" class="municipal-card">
        <div class="municipal-card-header">
        <h5>Paso 2: Asignación de Nueva Unidad ({{ contratosSeleccionados.length }} seleccionados)</h5>
      </div>
        <div class="municipal-card-body">
          <div class="alert alert-info">
            <font-awesome-icon icon="info-circle" class="me-2" />
            Esta operación reasignará la unidad recolectora de los contratos seleccionados.
          </div>

          <div class="row mb-3">
            <div class="col-md-4">
              <label class="municipal-form-label">Nueva Unidad *</label>
              <select class="municipal-form-control" v-model="nuevaUnidad">
                <option value="">Seleccione una unidad</option>
                <option v-for="u in unidades" :key="u.num_unidad" :value="u.num_unidad">
                  {{ u.nombre_unidad }} - {{ u.descripcion }}
                </option>
              </select>
            </div>
            <div class="col-md-4">
              <label class="municipal-form-label">Fecha de Aplicación *</label>
              <input type="date" class="municipal-form-control" v-model="fechaAplicacion" />
            </div>
            <div class="col-md-4">
              <label class="municipal-form-label">Motivo *</label>
              <input type="text" class="municipal-form-control" v-model="motivo"
                placeholder="Ej: Reorganización de rutas" />
            </div>
          </div>

          <div v-if="nuevaUnidad" class="alert alert-warning">
            <strong>Unidad a asignar:</strong>
            {{ obtenerNombreUnidad(nuevaUnidad) }}
          </div>

          <div class="d-flex justify-content-end">
            <button class="btn-municipal-secondary me-2" @click="cancelar">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
            <button class="btn-municipal-primary" @click="actualizarUnidades"
              :disabled="!validarActualizacion()">
              <font-awesome-icon icon="save" /> Actualizar Unidades
            </button>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Actualización de Unidades Recolectoras">
      <h6>Descripción</h6>
      <p>Permite reasignar masivamente la unidad recolectora de múltiples contratos.</p>
      <h6>Proceso</h6>
      <ol>
        <li>Buscar contratos por zona, unidad actual o tipo de aseo</li>
        <li>Seleccionar los contratos a modificar</li>
        <li>Asignar nueva unidad recolectora</li>
        <li>Confirmar la actualización</li>
      </ol>
      <h6>Casos de Uso</h6>
      <ul>
        <li>Reorganización de rutas de recolección</li>
        <li>Cambio de unidad por mantenimiento</li>
        <li>Optimización de zonas de servicio</li>
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
const zonas = ref([])
const unidades = ref([])
const contratosSeleccionados = ref([])
const seleccionarTodo = ref(false)
const nuevaUnidad = ref('')
const fechaAplicacion = ref(new Date().toISOString().split('T')[0])
const motivo = ref('')

const filtros = ref({
  zona: '',
  unidadActual: '',
  tipoAseo: ''
})

const buscarContratos = async () => {
  cargando.value = true
  try {
    const params = {
      p_zona: filtros.value.zona || null,
      p_unidad_actual: filtros.value.unidadActual || null,
      p_tipo_aseo: filtros.value.tipoAseo || null
    }
    const response = await execute('SP_ASEO_CONTRATOS_PARA_UPD_UNIDAD', 'aseo_contratado', params)
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

const validarActualizacion = () => {
  if (contratosSeleccionados.value.length === 0) return false
  if (!nuevaUnidad.value) return false
  if (!fechaAplicacion.value) return false
  if (!motivo.value.trim()) return false
  return true
}

const obtenerNombreUnidad = (numUnidad) => {
  const unidad = unidades.value.find(u => u.num_unidad === numUnidad)
  return unidad ? `${unidad.nombre_unidad} - ${unidad.descripcion}` : ''
}

const actualizarUnidades = async () => {
  const result = await Swal.fire({
    title: '¿Actualizar Unidades?',
    html: `Se actualizarán <strong>${contratosSeleccionados.value.length}</strong> contrato(s)<br>
           Nueva unidad: <strong>${obtenerNombreUnidad(nuevaUnidad.value)}</strong>`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#0d6efd',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  cargando.value = true
  try {
    const params = {
      p_contratos: contratosSeleccionados.value.join(','),
      p_nueva_unidad: nuevaUnidad.value,
      p_fecha_aplicacion: fechaAplicacion.value,
      p_motivo: motivo.value
    }
    await execute('SP_ASEO_ACTUALIZAR_UNIDADES_CONTRATOS', 'aseo_contratado', params)

    await Swal.fire('¡Actualizado!', 'Las unidades han sido actualizadas correctamente', 'success')

    await buscarContratos()
    cancelar()
  } catch (error) {
    handleError(error, 'Error al actualizar unidades')
  } finally {
    cargando.value = false
  }
}

const cancelar = () => {
  contratosSeleccionados.value = []
  nuevaUnidad.value = ''
  fechaAplicacion.value = new Date().toISOString().split('T')[0]
  motivo.value = ''
  seleccionarTodo.value = false
}

const formatTipoAseo = (tipo) => {
  const tipos = { 'D': 'Dom', 'C': 'Com', 'I': 'Ind', 'S': 'Ser' }
  return tipos[tipo] || tipo
}

onMounted(async () => {
  try {
    const [respZonas, respUnidades] = await Promise.all([
      execute('SP_ASEO_ZONAS_LIST', 'aseo_contratado', {}),
      execute('SP_ASEO_UNIDADES_LIST', 'aseo_contratado', {})
    ])
    zonas.value = respZonas || []
    unidades.value = respUnidades || []
  } catch (error) {
    console.error('Error al cargar catálogos:', error)
  }
})
</script>
