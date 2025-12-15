<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="truck-moving" />
      </div>
      <div class="module-view-info">
        <h1>Actualización de Unidades por Colonia</h1>
        <p>Aseo Contratado - Asigna unidades recolectoras masivamente por colonia</p>
      </div>
    </div>

    <!-- Sin catálogo de colonias -->
    <div v-if="catalogosCargados && !hayColoniasDisponibles" class="municipal-card">
      <div class="municipal-card-body">
        <div class="empty-state">
          <div class="empty-state-icon" style="background: linear-gradient(135deg, #ed8936 0%, #dd6b20 100%);">
            <font-awesome-icon icon="map-marked-alt" />
          </div>
          <h4 class="empty-state-title">Catálogo de colonias no disponible</h4>
          <p class="empty-state-description">
            Este módulo requiere un catálogo de colonias configurado en el sistema
            para poder asignar unidades recolectoras por zona geográfica.
          </p>
          <div class="empty-state-suggestions">
            <p><strong>Para habilitar este módulo:</strong></p>
            <ul>
              <li>Configure el catálogo de colonias en el sistema</li>
              <li>Asocie las colonias con sus respectivas zonas</li>
              <li>Vincule los contratos con las colonias correspondientes</li>
            </ul>
          </div>
        </div>
      </div>
    </div>

    <!-- Contenido principal (solo si hay colonias disponibles) -->
    <template v-else-if="catalogosCargados && hayColoniasDisponibles">
      <!-- Paso 1: Selección de Colonia -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="map-marker-alt" class="me-2" />Paso 1: Selección de Colonia</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="form-label">Buscar Colonia</label>
              <input
                type="text"
                class="form-control"
                v-model="busquedaColonia"
                placeholder="Escriba el nombre de la colonia..."
                @input="filtrarColonias"
              />
            </div>
            <div class="form-group">
              <label class="form-label required">Seleccionar Colonia</label>
              <select class="form-control" v-model="coloniaSeleccionada" @change="cargarContratosColonia">
                <option value="">-- Seleccione una colonia --</option>
                <option v-for="col in coloniasFiltradas" :key="col.num_colonia" :value="col.num_colonia">
                  {{ col.nombre_colonia }} ({{ col.total_contratos }} contratos)
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="form-label">Zona de la Colonia</label>
              <input type="text" class="form-control" :value="zonaColonia" disabled />
            </div>
          </div>
        </div>
      </div>

      <!-- Tabla de Contratos -->
      <div v-if="contratos.length > 0" class="municipal-card">
        <div class="municipal-card-header d-flex justify-content-between align-items-center">
          <h5>
            <font-awesome-icon icon="file-contract" class="me-2" />
            Contratos en la Colonia ({{ contratos.length }})
          </h5>
          <div class="button-group">
            <span class="badge badge-success">{{ contratosActivos }} Activos</span>
            <span class="badge badge-secondary">{{ contratosCancelados }} Cancelados</span>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive" style="max-height: 350px; overflow-y: auto;">
            <table class="municipal-table">
              <thead>
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
                <tr
                  v-for="contrato in contratos"
                  :key="contrato.control_contrato"
                  :class="{ 'row-inactive': contrato.status === 'I' }"
                >
                  <td>{{ contrato.num_contrato }}</td>
                  <td>{{ contrato.contribuyente }}</td>
                  <td>{{ contrato.domicilio_corto }}</td>
                  <td>
                    <span class="badge" :class="getBadgeTipo(contrato.cve_tipoaseo)">
                      {{ contrato.tipo_aseo }}
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

      <!-- Estado sin contratos en la colonia -->
      <div v-else-if="coloniaSeleccionada && busquedaRealizada" class="municipal-card">
        <div class="municipal-card-body">
          <div class="empty-state">
            <div class="empty-state-icon">
              <font-awesome-icon icon="home" />
            </div>
            <h4 class="empty-state-title">No hay contratos en esta colonia</h4>
            <p class="empty-state-description">
              La colonia seleccionada no tiene contratos registrados en el sistema.
            </p>
            <button class="btn-municipal-secondary mt-3" @click="cancelar">
              <font-awesome-icon icon="arrow-left" /> Seleccionar otra colonia
            </button>
          </div>
        </div>
      </div>

      <!-- Estado inicial -->
      <div v-else-if="!coloniaSeleccionada" class="municipal-card">
        <div class="municipal-card-body">
          <div class="empty-state initial-state">
            <div class="empty-state-icon pulse">
              <font-awesome-icon icon="truck-moving" />
            </div>
            <h4 class="empty-state-title">Seleccione una colonia</h4>
            <p class="empty-state-description">
              Utilice los filtros anteriores para seleccionar una colonia y actualizar
              las unidades recolectoras de sus contratos.
            </p>
            <div class="empty-state-steps">
              <div class="step">
                <div class="step-number">1</div>
                <div class="step-text">Busque y seleccione una colonia</div>
              </div>
              <div class="step">
                <div class="step-number">2</div>
                <div class="step-text">Revise los contratos de la colonia</div>
              </div>
              <div class="step">
                <div class="step-number">3</div>
                <div class="step-text">Seleccione la nueva unidad</div>
              </div>
              <div class="step">
                <div class="step-number">4</div>
                <div class="step-text">Aplique la actualización masiva</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Paso 2: Asignación de Nueva Unidad -->
      <div v-if="contratos.length > 0" class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="truck" class="me-2" />Paso 2: Asignación de Nueva Unidad</h5>
        </div>
        <div class="municipal-card-body">
          <div class="municipal-alert municipal-alert-info mb-3">
            <font-awesome-icon icon="info-circle" class="me-2" />
            La unidad se asignará a <strong>todos los contratos activos</strong> de la colonia seleccionada.
            Los contratos cancelados no se modificarán.
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="form-label required">Nueva Unidad Recolectora</label>
              <select class="form-control" v-model="nuevaUnidad">
                <option value="">Seleccione una unidad</option>
                <option v-for="u in unidades" :key="u.num_unidad" :value="u.num_unidad">
                  {{ u.nombre_unidad }} - {{ u.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="form-label required">Fecha de Aplicación</label>
              <input type="date" class="form-control" v-model="fechaAplicacion" />
            </div>
            <div class="form-group" style="flex: 2;">
              <label class="form-label required">Motivo</label>
              <input
                type="text"
                class="form-control"
                v-model="motivo"
                placeholder="Ej: Reorganización de rutas por colonia"
              />
            </div>
          </div>

          <div v-if="nuevaUnidad" class="municipal-alert municipal-alert-success mb-3">
            <strong>Resumen:</strong> Se asignará la unidad <strong>{{ obtenerNombreUnidad(nuevaUnidad) }}</strong>
            a {{ contratosActivos }} contrato(s) activo(s) de la colonia.
          </div>

          <div class="form-actions">
            <button class="btn-municipal-secondary" @click="cancelar">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
            <button
              class="btn-municipal-primary"
              @click="aplicarActualizacion"
              :disabled="!validarActualizacion()"
            >
              <font-awesome-icon icon="save" /> Aplicar Actualización
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
                <div class="stat-number">{{ resultado.contratos_procesados }}</div>
                <div class="stat-label">Contratos Procesados</div>
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
    </template>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
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
const colonias = ref([])
const coloniasFiltradas = ref([])
const contratos = ref([])
const unidades = ref([])
const busquedaColonia = ref('')
const coloniaSeleccionada = ref('')
const nuevaUnidad = ref('')
const fechaAplicacion = ref(new Date().toISOString().split('T')[0])
const motivo = ref('')
const busquedaRealizada = ref(false)
const resultado = ref(null)
const catalogosCargados = ref(false)

// Computed
const hayColoniasDisponibles = computed(() => {
  return colonias.value.length > 0 && colonias.value[0].num_colonia !== 0
})

const zonaColonia = computed(() => {
  if (!coloniaSeleccionada.value) return ''
  const colonia = colonias.value.find(c => c.num_colonia === coloniaSeleccionada.value)
  return colonia ? `Zona ${colonia.zona}` : ''
})

const contratosActivos = computed(() => {
  return contratos.value.filter(c => c.status === 'A').length
})

const contratosCancelados = computed(() => {
  return contratos.value.filter(c => c.status === 'I' || c.status !== 'A').length
})

// Métodos
const cargarCatalogos = async () => {
  showLoading()
  try {
    const [respColonias, respUnidades] = await Promise.all([
      execute('sp_aseo_colonias_list', BASE_DB, [], '', null, SCHEMA),
      execute('sp_aseo_unidades_list', BASE_DB, [], '', null, SCHEMA)
    ])
    colonias.value = respColonias?.result || []
    coloniasFiltradas.value = colonias.value
    unidades.value = respUnidades?.result || []
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cargar catálogos')
  } finally {
    catalogosCargados.value = true
    hideLoading()
  }
}

const filtrarColonias = () => {
  if (!busquedaColonia.value) {
    coloniasFiltradas.value = colonias.value
    return
  }
  const busqueda = busquedaColonia.value.toLowerCase()
  coloniasFiltradas.value = colonias.value.filter(c =>
    c.nombre_colonia?.toLowerCase().includes(busqueda)
  )
}

const cargarContratosColonia = async () => {
  if (!coloniaSeleccionada.value) {
    contratos.value = []
    busquedaRealizada.value = false
    return
  }

  showLoading()
  busquedaRealizada.value = true
  resultado.value = null

  try {
    const params = [
      { nombre: 'p_num_colonia', valor: parseInt(coloniaSeleccionada.value), tipo: 'integer' }
    ]
    const response = await execute('sp_aseo_contratos_list', BASE_DB, params, '', null, SCHEMA)
    contratos.value = response?.result || []

    if (contratos.value.length > 0) {
      showToast(`${contratos.value.length} contrato(s, 'success') encontrado(s)`)
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cargar contratos')
    contratos.value = []
  } finally {
    hideLoading()
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

  const confirmResult = await Swal.fire({
    title: '¿Actualizar Unidades?',
    html: `Se actualizarán <strong>${contratosActivos.value}</strong> contrato(s) activo(s)<br>
           de la colonia <strong>${colonia?.nombre_colonia || ''}</strong><br>
           Nueva unidad: <strong>${obtenerNombreUnidad(nuevaUnidad.value)}</strong>`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) return

  showLoading()

  let actualizados = 0
  let errores = 0

  try {
    // Filtrar solo contratos activos
    const contratosAActualizar = contratos.value.filter(c => c.status === 'A')

    for (const contrato of contratosAActualizar) {
      try {
        const params = [
          { nombre: 'p_control_contrato', valor: contrato.control_contrato, tipo: 'integer' },
          { nombre: 'p_unidades_recoleccion', valor: parseInt(nuevaUnidad.value), tipo: 'integer' }
        ]

        const response = await execute('sp_aseo_contratos_update', BASE_DB, params, '', null, SCHEMA)

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
        ? 'Todas las unidades fueron actualizadas correctamente'
        : `Completado con ${errores} error(es)`,
      contratos_procesados: contratosAActualizar.length,
      actualizaciones_exitosas: actualizados,
      errores: errores
    }

    await Swal.fire(
      '¡Proceso completado!',
      `Actualizados: ${actualizados}, Errores: ${errores}`,
      errores === 0 ? 'success' : 'warning'
    )

    // Refrescar lista
    await cargarContratosColonia()
    nuevaUnidad.value = ''
    motivo.value = ''

  } catch (error) {
    hideLoading()
    hideLoading()
    handleApiError(error, 'Error al actualizar unidades')
  }
}

const cancelar = () => {
  coloniaSeleccionada.value = ''
  contratos.value = []
  nuevaUnidad.value = ''
  motivo.value = ''
  busquedaColonia.value = ''
  coloniasFiltradas.value = colonias.value
  busquedaRealizada.value = false
  resultado.value = null
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

onMounted(() => {
  cargarCatalogos()
})
</script>

