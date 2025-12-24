<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="upload" />
      </div>
      <div class="module-view-info">
        <h1>Carga de Carteras</h1>
        <p>Otras Obligaciones - Generación de Carteras de Pago</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-info"
          @click="loadTablas"
          :disabled="loading"
          title="Actualizar"
        >
          <font-awesome-icon icon="sync" :spin="loading" />
          Actualizar
        </button>
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
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
      <!-- Selección de Tabla y Ejercicio -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Selección de Tabla y Ejercicio
          </h5>
        </div>

        <div class="municipal-card-body">
          <form @submit.prevent="handleAplica">
            <!-- Fila 1: Tabla a Cargar Cartera -->
            <div class="form-row">
              <div class="form-group full-width">
                <label class="municipal-form-label">
                  <strong>Tabla a Cargar Cartera</strong>
                  <span class="required">*</span>
                </label>
                <select
                  v-model="selectedTabla"
                  @change="onTablaChange"
                  class="municipal-form-control"
                  required
                  :disabled="loading"
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

            <!-- Fila 2: Ejercicio -->
            <div class="form-row" v-if="ejercicios.length > 0">
              <div class="form-group">
                <label class="municipal-form-label">
                  <strong>Ejercicio</strong>
                  <span class="required">*</span>
                </label>
                <select
                  v-model="selectedEjercicio"
                  @change="onEjercicioChange"
                  class="municipal-form-control"
                  required
                  :disabled="loading"
                >
                  <option value="">-- Seleccione ejercicio --</option>
                  <option
                    v-for="ej in ejercicios"
                    :key="ej.ejercicio"
                    :value="ej.ejercicio"
                  >
                    {{ ej.ejercicio }}
                  </option>
                </select>
              </div>
            </div>

            <!-- Tabla de Unidades -->
            <div class="form-row" v-if="unidades.length > 0">
              <div class="form-group full-width">
                <label class="municipal-form-label">
                  <strong>Unidades a Procesar</strong>
                </label>
                <div class="table-responsive">
                  <table class="municipal-table">
                    <thead class="municipal-table-header">
                      <tr>
                        <th>Ejercicio</th>
                        <th>Cve Unidad</th>
                        <th>Cve Operatividad</th>
                        <th>Descripción</th>
                        <th class="text-right">Costo</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr
                        v-for="unidad in unidades"
                        :key="`${unidad.cve_unidad}-${unidad.cve_operatividad}`"
                        class="row-hover"
                      >
                        <td>{{ unidad.ejercicio }}</td>
                        <td>{{ unidad.cve_unidad }}</td>
                        <td>{{ unidad.cve_operatividad }}</td>
                        <td>{{ unidad.descripcion }}</td>
                        <td class="text-right">{{ formatCurrency(unidad.costo) }}</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>

            <!-- Mensaje de no hay unidades -->
            <div v-if="selectedEjercicio && unidades.length === 0 && !loading" class="municipal-alert municipal-alert-info">
              <font-awesome-icon icon="info-circle" />
              No hay unidades para este ejercicio
            </div>

            <!-- Botones de Acción -->
            <div class="button-group" v-if="canApply">
              <button
                type="submit"
                class="btn-municipal-primary"
                :disabled="applying || loading"
              >
                <font-awesome-icon icon="check" />
                {{ applying ? 'Aplicando...' : 'Aplicar' }}
              </button>
            </div>
          </form>
        </div>
      </div>

    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocModal"
    :componentName="'CargaCartera'"
    :moduleName="'otras_obligaciones'"
    :docType="docType"
    :title="'Carga de Carteras'"
    @close="showDocModal = false"
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
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

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
const ejercicios = ref([])
const unidades = ref([])
const selectedTabla = ref('')
const selectedEjercicio = ref('')
const applying = ref(false)

// Computed
const canApply = computed(() => {
  return selectedTabla.value &&
         selectedEjercicio.value &&
         unidades.value.length > 0 &&
         !loading.value &&
         !applying.value
})

// Métodos de navegación
const goBack = () => {
  router.push('/otras_obligaciones')
}

// Cargar tablas
const loadTablas = async () => {
  // Limpiar selecciones previas
  selectedTabla.value = ''
  selectedEjercicio.value = ''
  ejercicios.value = []
  unidades.value = []

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

    loading.value = false
    hideLoading()

    if (response && response.result && response.result.length > 0) {
      tablas.value = response.result.map(t => ({
        cve_tab: String(t.cve_tab).trim(),
        nombre: (t.nombre || '').trim()
      }))
      showToast('success', `${tablas.value.length} tabla(s) cargada(s)`)
    } else {
      tablas.value = []
      showToast('info', 'No se encontraron tablas disponibles')
    }
  } catch (error) {
    loading.value = false
    hideLoading()
    handleApiError(error)
    tablas.value = []
  }
}

// Cargar ejercicios al cambiar tabla
const onTablaChange = async () => {
  // Limpiar selección previa
  selectedEjercicio.value = ''
  ejercicios.value = []
  unidades.value = []

  if (!selectedTabla.value) {
    return
  }

  loading.value = true
  showLoading('Cargando ejercicios...')

  try {
    const response = await execute(
      'sp_cargacartera_get_ejercicios',
      BASE_DB,
      [
        { nombre: 'par_cve_tab', valor: selectedTabla.value, tipo: 'varchar' }
      ],
      '',
      null,
      'public'
    )

    loading.value = false
    hideLoading()

    if (response && response.result && response.result.length > 0) {
      ejercicios.value = response.result.map(e => ({
        ejercicio: e.ejercicio
      }))

      // Auto-seleccionar el primer ejercicio
      if (ejercicios.value.length > 0) {
        selectedEjercicio.value = ejercicios.value[0].ejercicio
        await onEjercicioChange()
      }

      showToast('success', `${ejercicios.value.length} ejercicio(s) encontrado(s)`)
    } else {
      ejercicios.value = []
      showToast('info', 'No hay ejercicios para esta tabla')
    }
  } catch (error) {
    loading.value = false
    hideLoading()
    handleApiError(error)
    ejercicios.value = []
  }
}

// Cargar unidades al cambiar ejercicio
const onEjercicioChange = async () => {
  unidades.value = []

  if (!selectedTabla.value || !selectedEjercicio.value) {
    return
  }

  loading.value = true
  showLoading('Cargando unidades...')

  try {
    const response = await execute(
      'sp_cargacartera_get_unidades',
      BASE_DB,
      [
        { nombre: 'p_cve_tab', valor: selectedTabla.value, tipo: 'varchar' },
        { nombre: 'p_ejercicio', valor: selectedEjercicio.value, tipo: 'integer' }
      ],
      '',
      null,
      'public'
    )

    loading.value = false
    hideLoading()

    if (response && response.result && response.result.length > 0) {
      unidades.value = response.result.map(u => ({
        ejercicio: u.ejercicio,
        cve_unidad: u.cve_unidad?.trim() || '',
        cve_operatividad: u.cve_operatividad?.trim() || '',
        descripcion: u.descripcion?.trim() || '',
        costo: u.costo || 0
      }))
      showToast('success', `${unidades.value.length} unidad(es) encontrada(s)`)
    } else {
      unidades.value = []
      showToast('info', 'No hay unidades para este ejercicio')
    }
  } catch (error) {
    loading.value = false
    hideLoading()
    handleApiError(error)
    unidades.value = []
  }
}

// Aplicar carga de cartera
const handleAplica = async () => {
  if (!canApply.value) {
    await Swal.fire({
      icon: 'warning',
      title: 'Datos incompletos',
      text: 'Por favor seleccione tabla y ejercicio con unidades válidas',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  // Confirmación
  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Generar Cartera?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">¿Deseas GENERAR LA CARTERA con los siguientes datos?</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Tabla:</strong> ${selectedTabla.value}</li>
          <li style="margin: 5px 0;"><strong>Ejercicio:</strong> ${selectedEjercicio.value}</li>
          <li style="margin: 5px 0;"><strong>Unidades:</strong> ${unidades.value.length}</li>
        </ul>
        <p style="margin-top: 10px; color: #856404; background-color: #fff3cd; padding: 10px; border-radius: 4px;">
          <strong>Nota:</strong> Esta operación generará la cartera de pagos para todas las unidades seleccionadas.
        </p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, generar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    showToast('info', 'Operación cancelada')
    return
  }

  applying.value = true
  showLoading('Generando cartera...')

  try {
    const response = await execute(
      'con34_cgacart_01',
      BASE_DB,
      [
        { nombre: 'par_tabla', valor: selectedTabla.value, tipo: 'varchar' },
        { nombre: 'par_ejer', valor: selectedEjercicio.value, tipo: 'integer' }
      ],
      '',
      null,
      'public'
    )

    applying.value = false
    hideLoading()

    if (response && response.result && response.result.length > 0) {
      const result = response.result[0]
      const status = result.status
      const mensaje = result.concepto_status || 'Sin mensaje'

      if (status === 0) {
        await Swal.fire({
          icon: 'success',
          title: 'Operación Exitosa',
          html: `<p>${mensaje}</p>`,
          confirmButtonColor: '#ea8215',
          timer: 3000
        })
        showToast('success', mensaje)
      } else {
        await Swal.fire({
          icon: 'error',
          title: 'Error en la Operación',
          html: `<p><strong>Status:</strong> ${status}</p><p>${mensaje}</p>`,
          confirmButtonColor: '#ea8215'
        })
        showToast('error', mensaje)
      }
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: 'No se recibió respuesta del servidor',
        confirmButtonColor: '#ea8215'
      })
      showToast('error', 'Error inesperado en la operación')
    }
  } catch (error) {
    applying.value = false
    hideLoading()
    handleApiError(error)
    await Swal.fire({
      icon: 'error',
      title: 'Error de Comunicación',
      text: 'No se pudo completar la operación',
      confirmButtonColor: '#ea8215'
    })
  }
}

// Utilidades
const formatCurrency = (value) => {
  if (!value && value !== 0) return '$0.00'
  try {
    return new Intl.NumberFormat('es-MX', {
      style: 'currency',
      currency: 'MXN'
    }).format(value)
  } catch (error) {
    return `$${value}`
  }
}

// Lifecycle
onMounted(() => {
  loadTablas()
})
</script>
