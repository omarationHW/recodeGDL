<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="dollar-sign" />
      </div>
      <div class="module-view-info">
        <h1>Carga de Valores</h1>
        <p>Otras Obligaciones - Carga de Valores para Unidades</p>
      </div>
      <div class="button-group ms-auto">
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
          :disabled="loading"
        >
          <font-awesome-icon icon="arrow-left" />
          Salir
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Selector de Tabla -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="table" />
            Seleccionar Tabla a Cargar Valores
          </h5>
          <div v-if="loadingTablas" class="spinner-border spinner-border-sm" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
        </div>

        <div class="municipal-card-body">
          <div class="row g-3">
            <div class="col-12">
              <label class="municipal-form-label">
                <strong>Tabla a Cargar Valores:</strong>
                <span class="text-danger">*</span>
              </label>
              <select
                v-model="selectedTabla"
                @change="onTablaChange"
                class="municipal-form-control"
                :disabled="loadingTablas || loading"
              >
                <option value="">-- Seleccione una tabla --</option>
                <option
                  v-for="tabla in tablas"
                  :key="tabla.cve_tab"
                  :value="tabla.cve_tab"
                >
                  {{ tabla.cve_tab }} - {{ tabla.nombre }}
                </option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <!-- Grid de Valores -->
      <div class="municipal-card" v-if="selectedTabla">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list-alt" />
            Valores a Cargar
            <span class="badge badge-purple" v-if="valores.length > 0">{{ valores.length }} filas</span>
          </h5>
          <div v-if="loading" class="spinner-border spinner-border-sm" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
        </div>

        <div class="municipal-card-body">
          <!-- Tabla de valores editable -->
          <div class="table-responsive">
            <table class="municipal-table table-editable">
              <thead class="municipal-table-header">
                <tr>
                  <th class="text-center" style="width: 10%;">Ejercicio <span class="text-danger">*</span></th>
                  <th class="text-center" style="width: 12%;">Cve Und <span class="text-danger">*</span></th>
                  <th class="text-center" style="width: 12%;">Cve Oper <span class="text-danger">*</span></th>
                  <th style="width: 40%;">Descripción <span class="text-danger">*</span></th>
                  <th class="text-end" style="width: 16%;">Costo <span class="text-danger">*</span></th>
                  <th class="text-center" style="width: 10%;">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in valores" :key="idx" class="row-editable">
                  <td>
                    <input
                      v-model.number="row.ejercicio"
                      type="number"
                      min="2000"
                      max="2100"
                      class="form-control form-control-sm"
                      :class="{'is-invalid': !isValidEjercicio(row.ejercicio)}"
                      placeholder="YYYY"
                    />
                  </td>
                  <td>
                    <input
                      v-model="row.cve_unidad"
                      type="text"
                      maxlength="1"
                      class="form-control form-control-sm"
                      :class="{'is-invalid': !isValidCveUnidad(row.cve_unidad)}"
                      placeholder="U"
                    />
                  </td>
                  <td>
                    <input
                      v-model="row.cve_operatividad"
                      type="text"
                      maxlength="1"
                      class="form-control form-control-sm"
                      :class="{'is-invalid': !isValidCveOperatividad(row.cve_operatividad)}"
                      placeholder="O"
                    />
                  </td>
                  <td>
                    <input
                      v-model="row.descripcion"
                      type="text"
                      maxlength="100"
                      class="form-control form-control-sm"
                      :class="{'is-invalid': !isValidDescripcion(row.descripcion)}"
                      placeholder="Descripción de la unidad"
                    />
                  </td>
                  <td>
                    <input
                      v-model.number="row.costo"
                      type="number"
                      min="0"
                      step="0.01"
                      class="form-control form-control-sm"
                      :class="{'is-invalid': !isValidCosto(row.costo)}"
                      placeholder="0.00"
                    />
                  </td>
                  <td class="text-center">
                    <button
                      type="button"
                      class="btn btn-sm btn-danger"
                      @click="removeRow(idx)"
                      :disabled="valores.length <= 1"
                      title="Eliminar fila"
                    >
                      <font-awesome-icon icon="trash" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Botones para agregar/eliminar filas -->
          <div class="button-group mt-3">
            <button
              type="button"
              class="btn-municipal-secondary"
              @click="addRow"
            >
              <font-awesome-icon icon="plus" />
              Agregar Fila
            </button>
          </div>

          <!-- Información de validación -->
          <div class="alert alert-info d-flex align-items-center mt-3" v-if="valores.length > 0">
            <font-awesome-icon icon="info-circle" class="me-2" />
            <div>
              <strong>Información:</strong> Se insertarán {{ filasValidas }} de {{ valores.length }} filas.
              <span v-if="filasInvalidas > 0" class="text-warning ms-2">
                <font-awesome-icon icon="exclamation-triangle" class="me-1" />
                {{ filasInvalidas }} fila(s) incompleta(s) serán omitidas
              </span>
            </div>
          </div>

          <!-- Botones de acción -->
          <div class="button-group mt-4">
            <button
              type="button"
              class="btn-municipal-primary"
              @click="aplicaValores"
              :disabled="!canApply || saving"
            >
              <font-awesome-icon :icon="saving ? 'spinner' : 'check'" :spin="saving" />
              {{ saving ? 'Guardando...' : 'Aplicar Valores' }}
            </button>
            <button
              type="button"
              class="btn-municipal-secondary"
              @click="goBack"
              :disabled="loading || saving"
            >
              <font-awesome-icon icon="times" />
              Cancelar
            </button>
          </div>
        </div>
      </div>

      <!-- Mensaje cuando no hay tabla seleccionada -->
      <div class="municipal-card" v-else-if="!loadingTablas">
        <div class="municipal-card-body">
          <div class="text-center text-muted py-5">
            <font-awesome-icon icon="table" size="3x" class="mb-3 opacity-50" />
            <p class="mb-0">Por favor seleccione una tabla para cargar valores.</p>
          </div>
        </div>
      </div>

      <!-- Loading overlay -->
      <div v-if="loading" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>Cargando datos...</p>
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
    :componentName="'CargaValores'"
    :moduleName="'otras_obligaciones'"
    @close="closeDocumentation"
  />
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

// Router
const router = useRouter()

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
const tablas = ref([])
const valores = ref([])
const selectedTabla = ref('')
const loadingTablas = ref(false)
const saving = ref(false)

// Año actual por defecto
const currentYear = new Date().getFullYear()

// Computed
const filasValidas = computed(() => {
  return valores.value.filter(row => isRowValid(row)).length
})

const filasInvalidas = computed(() => {
  return valores.value.length - filasValidas.value
})

const canApply = computed(() => {
  return selectedTabla.value && filasValidas.value > 0 && !saving.value
})

// Validaciones
const isValidEjercicio = (ejercicio) => {
  return ejercicio && ejercicio >= 2000 && ejercicio <= 2100
}

const isValidCveUnidad = (cve) => {
  return cve && cve.trim() !== ''
}

const isValidCveOperatividad = (cve) => {
  return cve && cve.trim() !== ''
}

const isValidDescripcion = (desc) => {
  return desc && desc.trim() !== ''
}

const isValidCosto = (costo) => {
  return costo !== null && costo !== undefined && costo >= 0
}

const isRowValid = (row) => {
  return isValidEjercicio(row.ejercicio) &&
         isValidCveUnidad(row.cve_unidad) &&
         isValidCveOperatividad(row.cve_operatividad) &&
         isValidDescripcion(row.descripcion) &&
         isValidCosto(row.costo)
}

// Métodos
const goBack = () => {
  router.push('/otras_obligaciones')
}

// Cargar tablas disponibles
const loadTablas = async () => {
  loadingTablas.value = true
  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_get_tablas',
      'otras_obligaciones',
      [],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      tablas.value = response.result.map(tabla => ({
        id_34_tab: tabla.id_34_tab,
        cve_tab: tabla.cve_tab,
        nombre: tabla.nombre
      }))

      const duration = ((performance.now() - startTime) / 1000).toFixed(2)
      showToast('success', `${tablas.value.length} tabla(s) disponible(s) (${duration}s)`)
    } else {
      tablas.value = []
      showToast('info', 'No se encontraron tablas disponibles')
    }
  } catch (error) {
    handleApiError(error)
    tablas.value = []
  } finally {
    loadingTablas.value = false
  }
}

// Evento al cambiar la tabla seleccionada
const onTablaChange = async () => {
  if (!selectedTabla.value) {
    valores.value = []
    return
  }

  setLoading(true, 'Cargando unidades...')
  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_get_unidades_by_tabla',
      'otras_obligaciones',
      [
        { nombre: 'p_cve_tab', valor: selectedTabla.value, tipo: 'string' }
      ],
      'guadalajara'
    )

    const duration = ((performance.now() - startTime) / 1000).toFixed(2)

    if (response && response.result && response.result.length > 0) {
      // Pre-cargar con los datos del ejercicio actual + 1
      valores.value = response.result.map(unidad => ({
        ejercicio: unidad.ejercicio + 1, // Siguiente ejercicio
        cve_unidad: unidad.cve_unidad,
        cve_operatividad: unidad.cve_operatividad,
        descripcion: unidad.descripcion,
        costo: 0 // Costo en 0 para que el usuario lo capture
      }))

      showToast('success', `${valores.value.length} unidad(es) cargada(s) para el ejercicio ${currentYear + 1} (${duration}s)`)
    } else {
      // Si no hay datos, crear filas vacías
      valores.value = Array.from({ length: 10 }, () => createEmptyRow())
      showToast('info', 'No se encontraron unidades previas. Se crearon 10 filas vacías.')
    }
  } catch (error) {
    handleApiError(error)
    // En caso de error, crear filas vacías
    valores.value = Array.from({ length: 10 }, () => createEmptyRow())
  } finally {
    setLoading(false)
  }
}

// Crear fila vacía
const createEmptyRow = () => ({
  ejercicio: currentYear + 1,
  cve_unidad: '',
  cve_operatividad: '',
  descripcion: '',
  costo: 0
})

// Agregar fila
const addRow = () => {
  valores.value.push(createEmptyRow())
  showToast('info', 'Fila agregada')
}

// Eliminar fila
const removeRow = (index) => {
  if (valores.value.length > 1) {
    valores.value.splice(index, 1)
    showToast('info', 'Fila eliminada')
  } else {
    showToast('warning', 'Debe mantener al menos una fila')
  }
}

// Aplicar valores (insertar en BD)
const aplicaValores = async () => {
  if (!selectedTabla.value) {
    showToast('error', 'Debe seleccionar una tabla')
    return
  }

  // Filtrar solo las filas válidas
  const filasParaInsertar = valores.value.filter(row => isRowValid(row))

  if (filasParaInsertar.length === 0) {
    await Swal.fire({
      icon: 'warning',
      title: 'Sin datos válidos',
      text: 'Debe capturar al menos un valor válido con todos los campos completos.',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  // Confirmación
  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar inserción de valores?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se insertarán <strong>${filasParaInsertar.length}</strong> valor(es) en la tabla <strong>${selectedTabla.value}</strong>:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Ejercicio(s):</strong> ${[...new Set(filasParaInsertar.map(f => f.ejercicio))].join(', ')}</li>
          <li style="margin: 5px 0;"><strong>Total de filas:</strong> ${filasParaInsertar.length}</li>
        </ul>
        ${filasInvalidas.value > 0 ? `<p style="color: #856404; margin-top: 10px;"><em>Nota: ${filasInvalidas.value} fila(s) incompleta(s) serán omitidas.</em></p>` : ''}
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, insertar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  saving.value = true
  let insertados = 0
  let errores = 0
  const mensajesError = []
  const startTime = performance.now()

  try {
    // Preparar el array JSON con las unidades
    const unidadesJSON = filasParaInsertar.map(row => ({
      ejercicio: row.ejercicio,
      cve_unidad: row.cve_unidad.trim(),
      cve_operatividad: row.cve_operatividad.trim(),
      descripcion: row.descripcion.trim(),
      costo: row.costo
    }))

    // Insertar todas las filas en una sola llamada
    try {
      const response = await execute(
        'sp_insert_unidades',
        'otras_obligaciones',
        [
          { nombre: 'p_cve_tab', valor: selectedTabla.value, tipo: 'string' },
          { nombre: 'p_unidades', valor: JSON.stringify(unidadesJSON), tipo: 'jsonb' }
        ],
        'guadalajara'
      )

      if (response && response.result) {
        insertados = filasParaInsertar.length
      } else {
        errores = filasParaInsertar.length
        mensajesError.push('Error al insertar las unidades')
      }
    } catch (error) {
      errores = filasParaInsertar.length
      mensajesError.push(error.message || 'Error al insertar las unidades')
    }

    const duration = ((performance.now() - startTime) / 1000).toFixed(2)

    // Mostrar resultado
    if (insertados > 0 && errores === 0) {
      await Swal.fire({
        icon: 'success',
        title: 'Inserción exitosa',
        html: `
          <div style="text-align: center;">
            <p style="font-size: 1.1em; margin: 10px 0;">Se insertaron correctamente <strong>${insertados}</strong> valor(es).</p>
            <p style="font-size: 0.9em; color: #6c757d;">Tiempo: ${duration}s</p>
          </div>
        `,
        confirmButtonColor: '#ea8215',
        timer: 3000
      })

      showToast('success', `${insertados} valor(es) insertado(s) correctamente (${duration}s)`)

      // Recargar las unidades
      await onTablaChange()
    } else if (insertados > 0 && errores > 0) {
      await Swal.fire({
        icon: 'warning',
        title: 'Inserción parcial',
        html: `
          <div style="text-align: left; padding: 0 20px;">
            <p><strong>Insertados:</strong> ${insertados}</p>
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

      showToast('warning', `${insertados} insertado(s), ${errores} error(es)`)

      // Recargar las unidades
      await onTablaChange()
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al insertar',
        html: `
          <div style="text-align: left; padding: 0 20px;">
            <p>No se pudo insertar ningún valor.</p>
            <hr>
            <p style="margin-top: 10px;"><strong>Detalles de errores:</strong></p>
            <ul style="max-height: 200px; overflow-y: auto; font-size: 0.9em;">
              ${mensajesError.map(msg => `<li>${msg}</li>`).join('')}
            </ul>
          </div>
        `,
        confirmButtonColor: '#ea8215'
      })

      showToast('error', 'No se insertaron valores')
    }
  } catch (error) {
    handleApiError(error)
    await Swal.fire({
      icon: 'error',
      title: 'Error de conexión',
      text: 'No se pudieron insertar los valores',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    saving.value = false
  }
}

// Lifecycle
onMounted(() => {
  loadTablas()
})
</script>
