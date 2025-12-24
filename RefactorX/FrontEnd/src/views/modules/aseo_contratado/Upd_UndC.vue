<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="truck-moving" />
      </div>
      <div class="module-view-info">
        <h1>Actualización de Unidades por Colonia</h1>
        <p>Asigna unidades recolectoras masivamente por colonia</p>
      </div>
      <button type="button" class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Paso 1: Selección de Colonia</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Buscar Colonia</label>
              <input type="text" class="municipal-form-control" v-model="busquedaColonia"
                placeholder="Escriba el nombre de la colonia..." @input="filtrarColonias" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Seleccionar Colonia <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="coloniaSeleccionada" @change="cargarContratosColonia">
                <option value="">-- Seleccione una colonia --</option>
                <option v-for="col in coloniasFiltradas" :key="col.num_colonia" :value="col.num_colonia">
                  {{ col.nombre_colonia }} ({{ col.total_contratos }} contratos)
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Zona de la Colonia</label>
              <input type="text" class="municipal-form-control" :value="zonaColonia" disabled />
            </div>
          </div>
        </div>
      </div>

      <div v-if="contratos.length > 0">
        <div class="municipal-card">
          <div class="municipal-card-header">
            <h5>
              Contratos en la Colonia ({{ contratos.length }})
              <span class="badge-success">{{ contratosActivos }} Activos</span>
              <span class="badge-secondary">{{ contratosCancelados }} Cancelados</span>
            </h5>
          </div>
          <div class="municipal-card-body">
            <div class="table-responsive" style="max-height: 350px; overflow-y: auto;">
              <table class="municipal-table">
                <thead class="municipal-table-header" style="position: sticky; top: 0;">
                  <tr>
                    <th>Contrato</th>
                    <th>Contribuyente</th>
                    <th>Domicilio</th>
                    <th>Tipo</th>
                    <th>Unidad Actual</th>
                    <th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="contrato in contratos" :key="contrato.control_contrato"
                      :class="{ 'row-inactive': contrato.status === 'I' }">
                    <td>{{ contrato.num_contrato }}</td>
                    <td>{{ contrato.contribuyente }}</td>
                    <td>{{ contrato.domicilio_corto }}</td>
                    <td>
                      <span class="badge" :class="getBadgeTipo(contrato.tipo_aseo)">
                        {{ formatTipoAseo(contrato.tipo_aseo) }}
                      </span>
                    </td>
                    <td>{{ contrato.unidad_actual || 'Sin asignar' }}</td>
                    <td>
                      <span class="badge" :class="contrato.status === 'A' ? 'badge-success' : 'badge-secondary'">
                        {{ contrato.status === 'A' ? 'Activo' : 'Cancelado' }}
                      </span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <div class="municipal-card">
          <div class="municipal-card-header">
            <h5>Paso 2: Asignación de Nueva Unidad</h5>
          </div>
          <div class="municipal-card-body">
            <div class="alert-info">
              <font-awesome-icon icon="info-circle" />
              La unidad se asignará a <strong>todos los contratos activos</strong> de la colonia seleccionada.
              Los contratos cancelados no se modificarán.
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Nueva Unidad Recolectora <span class="required">*</span></label>
                <select class="municipal-form-control" v-model="nuevaUnidad">
                  <option value="">Seleccione una unidad</option>
                  <option v-for="u in unidades" :key="u.num_unidad" :value="u.num_unidad">
                    {{ u.nombre_unidad }} - {{ u.descripcion }}
                  </option>
                </select>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Fecha de Aplicación <span class="required">*</span></label>
                <input type="date" class="municipal-form-control" v-model="fechaAplicacion" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Motivo <span class="required">*</span></label>
                <input type="text" class="municipal-form-control" v-model="motivo"
                  placeholder="Ej: Reorganización de rutas por colonia" />
              </div>
            </div>

            <div v-if="nuevaUnidad" class="alert-success">
              <strong>Resumen:</strong> Se asignará la unidad <strong>{{ obtenerNombreUnidad(nuevaUnidad) }}</strong>
              a {{ contratosActivos }} contrato(s) activo(s) de la colonia.
            </div>

            <div class="button-group">
              <button class="btn-municipal-secondary" @click="cancelar">
                <font-awesome-icon icon="times" /> Cancelar
              </button>
              <button class="btn-municipal-primary" @click="aplicarActualizacion"
                :disabled="!validarActualizacion()">
                <font-awesome-icon icon="save" /> Aplicar Actualización
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal
      :show="showDocumentation"
      :componentName="'Upd_UndC'"
      :moduleName="'aseo_contratado'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { handleApiError } = useLicenciasErrorHandler()

const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const cargando = ref(false)
const colonias = ref([])
const coloniasFiltradas = ref([])
const contratos = ref([])
const unidades = ref([])
const busquedaColonia = ref('')
const coloniaSeleccionada = ref('')
const nuevaUnidad = ref('')
const fechaAplicacion = ref(new Date().toISOString().split('T')[0])
const motivo = ref('')

const zonaColonia = computed(() => {
  if (!coloniaSeleccionada.value) return ''
  const colonia = colonias.value.find(c => c.num_colonia === coloniaSeleccionada.value)
  return colonia ? `Zona ${colonia.zona}` : ''
})

const contratosActivos = computed(() => {
  return contratos.value.filter(c => c.status === 'A').length
})

const contratosCancelados = computed(() => {
  return contratos.value.filter(c => c.status === 'I').length
})

const filtrarColonias = () => {
  if (!busquedaColonia.value) {
    coloniasFiltradas.value = colonias.value
    return
  }
  const busqueda = busquedaColonia.value.toLowerCase()
  coloniasFiltradas.value = colonias.value.filter(c =>
    c.nombre_colonia.toLowerCase().includes(busqueda)
  )
}

const cargarContratosColonia = async () => {
  if (!coloniaSeleccionada.value) {
    contratos.value = []
    return
  }

  cargando.value = true
  try {
    const params = { p_num_colonia: coloniaSeleccionada.value }
    const response = await execute('SP_ASEO_CONTRATOS_POR_COLONIA', 'aseo_contratado', params)
    contratos.value = response || []
  } catch (error) {
    handleApiError(error)
  } finally {
    cargando.value = false
  }
}

const validarActualizacion = () => {
  if (!coloniaSeleccionada.value) return false
  if (!nuevaUnidad.value) return false
  if (!fechaAplicacion.value) return false
  if (!motivo.value.trim()) return false
  if (contratosActivos.value === 0) return false
  return true
}

const obtenerNombreUnidad = (numUnidad) => {
  const unidad = unidades.value.find(u => u.num_unidad === numUnidad)
  return unidad ? `${unidad.nombre_unidad} - ${unidad.descripcion}` : ''
}

const aplicarActualizacion = async () => {
  const colonia = colonias.value.find(c => c.num_colonia === coloniaSeleccionada.value)

  const result = await Swal.fire({
    title: '¿Actualizar Unidades?',
    html: `Se actualizarán <strong>${contratosActivos.value}</strong> contrato(s) activo(s)<br>
           de la colonia <strong>${colonia.nombre_colonia}</strong><br>
           Nueva unidad: <strong>${obtenerNombreUnidad(nuevaUnidad.value)}</strong>`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  cargando.value = true
  try {
    const params = {
      p_num_colonia: coloniaSeleccionada.value,
      p_nueva_unidad: nuevaUnidad.value,
      p_fecha_aplicacion: fechaAplicacion.value,
      p_motivo: motivo.value
    }
    await execute('SP_ASEO_ACTUALIZAR_UNIDAD_POR_COLONIA', 'aseo_contratado', params)

    await Swal.fire('¡Actualizado!', 'Las unidades han sido actualizadas correctamente', 'success')

    await cargarContratosColonia()
    nuevaUnidad.value = ''
    motivo.value = ''
  } catch (error) {
    handleApiError(error)
  } finally {
    cargando.value = false
  }
}

const cancelar = () => {
  coloniaSeleccionada.value = ''
  contratos.value = []
  nuevaUnidad.value = ''
  motivo.value = ''
  busquedaColonia.value = ''
  coloniasFiltradas.value = colonias.value
}

const formatTipoAseo = (tipo) => {
  const tipos = { 'D': 'Dom', 'C': 'Com', 'I': 'Ind', 'S': 'Ser' }
  return tipos[tipo] || tipo
}

const getBadgeTipo = (tipo) => {
  const colores = {
    'D': 'badge-success',
    'C': 'badge-primary',
    'I': 'badge-warning',
    'S': 'badge-info'
  }
  return colores[tipo] || 'badge-secondary'
}

onMounted(async () => {
  try {
    const [respColonias, respUnidades] = await Promise.all([
      execute('SP_ASEO_COLONIAS_CON_CONTRATOS', 'aseo_contratado', {}),
      execute('SP_ASEO_UNIDADES_LIST', 'aseo_contratado', {})
    ])
    colonias.value = respColonias || []
    coloniasFiltradas.value = colonias.value
    unidades.value = respUnidades || []
  } catch (error) {
    console.error('Error al cargar catálogos:', error)
  }
})
</script>
