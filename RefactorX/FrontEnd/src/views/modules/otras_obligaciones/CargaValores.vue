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
          class="btn-municipal-info"
          @click="loadTablas"
          :disabled="loading || loadingTablas"
          title="Actualizar"
        >
          <font-awesome-icon icon="sync" :spin="loading || loadingTablas" />
          Actualizar
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
        </div>

        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">
                <strong>Tabla a Cargar Valores</strong>
                <span class="required">*</span>
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
                      class="municipal-form-control municipal-form-control-sm"
                      :class="{'is-invalid': !isValidEjercicio(row.ejercicio)}"
                      placeholder="YYYY"
                    />
                  </td>
                  <td>
                    <input
                      v-model="row.cve_unidad"
                      type="text"
                      maxlength="1"
                      class="municipal-form-control municipal-form-control-sm text-center text-uppercase"
                      :class="{'is-invalid': !isValidCveUnidad(row.cve_unidad)}"
                      placeholder="U"
                    />
                  </td>
                  <td>
                    <input
                      v-model="row.cve_operatividad"
                      type="text"
                      maxlength="1"
                      class="municipal-form-control municipal-form-control-sm text-center text-uppercase"
                      :class="{'is-invalid': !isValidCveOperatividad(row.cve_operatividad)}"
                      placeholder="O"
                    />
                  </td>
                  <td>
                    <input
                      v-model="row.descripcion"
                      type="text"
                      maxlength="100"
                      class="municipal-form-control municipal-form-control-sm"
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
                      class="municipal-form-control municipal-form-control-sm text-end"
                      :class="{'is-invalid': !isValidCosto(row.costo)}"
                      placeholder="0.00"
                    />
                  </td>
                  <td class="text-center">
                    <button
                      type="button"
                      class="btn-municipal-danger btn-municipal-sm"
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
          <div class="municipal-alert municipal-alert-info mt-3" v-if="valores.length > 0">
            <font-awesome-icon icon="info-circle" class="me-2" />
            <strong>Información:</strong> Se insertarán {{ filasValidas }} de {{ valores.length }} filas.
            <span v-if="filasInvalidas > 0" class="municipal-alert municipal-alert-warning ms-2" style="display: inline; padding: 4px 8px;">
              <font-awesome-icon icon="exclamation-triangle" class="me-1" />
              {{ filasInvalidas }} fila(s) incompleta(s) serán omitidas
            </span>
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

    </div>
    <!-- /module-view-content -->
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
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

// Router
const router = useRouter()

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const BASE_DB = 'otras_obligaciones'
const { showLoading, hideLoading } = useGlobalLoading()
const {
  showToast,
  handleApiError
} = useLicenciasErrorHandler()

// Estado local para loading
const loading = ref(false)

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
  // Limpiar selecciones previas
  selectedTabla.value = ''
  valores.value = []

  loadingTablas.value = true
  loading.value = true
  showLoading('Cargando tablas...')

  try {
    const response = await execute(
      'sp_otras_oblig_get_tablas_all',
      BASE_DB,
      [],
      '',
      null,
      'public'
    )

    loadingTablas.value = false
    loading.value = false
    hideLoading()

    if (response && response.result && response.result.length > 0) {
      tablas.value = response.result.map(tabla => ({
        cve_tab: String(tabla.cve_tab).trim(),
        nombre: (tabla.nombre || '').trim()
      }))

      showToast('success', `${tablas.value.length} tabla(s) disponible(s)`)
    } else {
      tablas.value = []
      showToast('info', 'No se encontraron tablas disponibles')
    }
  } catch (error) {
    loadingTablas.value = false
    loading.value = false
    hideLoading()
    handleApiError(error)
    tablas.value = []
  }
}

// Evento al cambiar la tabla seleccionada
const onTablaChange = async () => {
  if (!selectedTabla.value) {
    valores.value = []
    return
  }

  loading.value = true
  showLoading('Cargando unidades...')

  try {
    const response = await execute(
      'sp_get_unidades_by_tabla',
      BASE_DB,
      [
        { nombre: 'p_cve_tab', valor: selectedTabla.value, tipo: 'varchar' }
      ],
      '',
      null,
      'public'
    )

    loading.value = false
    hideLoading()

    if (response && response.result && response.result.length > 0) {
      // Pre-cargar con los datos del ejercicio anterior + 1
      // Delphi: QryUnidades.ParamByName('ejer').AsInteger := StrToInt(FLabelEjercicio.Caption) + 1;
      const ejercicioAnterior = response.result[0].ejercicio
      valores.value = response.result.map(unidad => ({
        ejercicio: ejercicioAnterior + 1, // Siguiente ejercicio respecto al anterior en BD
        cve_unidad: unidad.cve_unidad,
        cve_operatividad: unidad.cve_operatividad,
        descripcion: unidad.descripcion,
        costo: 0 // Costo en 0 para que el usuario lo capture
      }))

      showToast('success', `${valores.value.length} unidad(es) cargada(s) para el ejercicio ${ejercicioAnterior + 1}`)
    } else {
      // Si no hay datos, crear filas vacías
      valores.value = Array.from({ length: 10 }, () => createEmptyRow())
      showToast('info', 'No se encontraron unidades previas. Se crearon 10 filas vacías.')
    }
  } catch (error) {
    loading.value = false
    hideLoading()
    handleApiError(error)
    // En caso de error, crear filas vacías
    valores.value = Array.from({ length: 10 }, () => createEmptyRow())
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
    showToast('info', 'Operación cancelada')
    return
  }

  saving.value = true
  showLoading('Insertando valores...')

  let insertados = 0
  let errores = 0
  const mensajesError = []

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
        'sp_cargavalores_insert_unidades',
        BASE_DB,
        [
          { nombre: 'p_cve_tab', valor: selectedTabla.value, tipo: 'varchar' },
          { nombre: 'p_unidades', valor: JSON.stringify(unidadesJSON), tipo: 'jsonb' }
        ],
        '',
        null,
        'public'
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

    saving.value = false
    hideLoading()

    // Mostrar resultado
    if (insertados > 0 && errores === 0) {
      await Swal.fire({
        icon: 'success',
        title: 'Inserción exitosa',
        html: `
          <div style="text-align: center;">
            <p style="font-size: 1.1em; margin: 10px 0;">Se insertaron correctamente <strong>${insertados}</strong> valor(es).</p>
          </div>
        `,
        confirmButtonColor: '#ea8215',
        timer: 3000
      })

      showToast('success', `${insertados} valor(es) insertado(s) correctamente`)

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
    saving.value = false
    hideLoading()
    handleApiError(error)
    await Swal.fire({
      icon: 'error',
      title: 'Error de conexión',
      text: 'No se pudieron insertar los valores',
      confirmButtonColor: '#ea8215'
    })
  }
}

// Lifecycle
onMounted(() => {
  loadTablas()
})
</script>
