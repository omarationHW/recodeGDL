<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="list" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Rubros</h1>
        <p>Otras Obligaciones - Gestión de rubros</p>
      </div>
      <button class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" @click="goBack">
          <font-awesome-icon icon="arrow-left" /> Salir
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="row">
        <div class="col-md-6">
          <div class="municipal-card">
            <div class="municipal-card-header">
              <h5><font-awesome-icon icon="plus" /> Crear Nuevo Rubro</h5>
            </div>
            <div class="municipal-card-body">
              <div class="form-group">
                <label class="municipal-form-label">Nombre del Rubro: <span class="required">*</span></label>
                <input type="text" v-model="formData.nombre" class="municipal-form-control" placeholder="Ingrese nombre del rubro" />
              </div>
              <div class="form-group">
                <button class="btn-municipal-primary" @click="handleCrear" :disabled="loading">
                  <font-awesome-icon icon="plus" /> Crear Rubro
                </button>
              </div>
            </div>
          </div>
        </div>

        <div class="col-md-6">
          <div class="municipal-card">
            <div class="municipal-card-header">
              <h5><font-awesome-icon icon="list" /> Rubros Existentes</h5>
              <button class="btn-municipal-secondary btn-sm" @click="cargarRubros" :disabled="loading">
                <font-awesome-icon icon="sync" /> Actualizar
              </button>
            </div>
            <div class="municipal-card-body">
              <div class="table-responsive">
                <table class="table table-municipal">
                  <thead>
                    <tr>
                      <th class="text-center">Clave</th>
                      <th>Nombre</th>
                      <th class="text-center">Auto</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="rubro in rubros" :key="rubro.cve_tab">
                      <td class="text-center">{{ rubro.cve_tab }}</td>
                      <td>{{ rubro.nombre }}</td>
                      <td class="text-center">
                        <span class="badge" :class="rubro.auto_tab ? 'badge-success' : 'badge-info'">
                          {{ rubro.auto_tab ? 'Sí' : 'No' }}
                        </span>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div v-if="loading" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>Procesando...</p>
        </div>
      </div>
    </div>

    <DocumentationModal
      :show="showDocumentation"
      :componentName="'Rubros'"
      :moduleName="'otras_obligaciones'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const router = useRouter()
const { callApi } = useApi()
const { handleError, showToast } = useLicenciasErrorHandler()

const loading = ref(false)
const showDocumentation = ref(false)
const rubros = ref([])

const formData = reactive({
  nombre: ''
})

const cargarRubros = async () => {
  loading.value = true
  try {
    const response = await callApi('SP_RUBROS_LISTAR', {})
    rubros.value = response.data || []
  } catch (error) {
    handleError(error, 'Error al cargar rubros')
  } finally {
    loading.value = false
  }
}

const handleCrear = async () => {
  if (!formData.nombre || formData.nombre.trim() === '') {
    showToast('warning', 'Debe ingresar el nombre del rubro')
    return
  }

  loading.value = true
  try {
    await callApi('SP_RUBROS_INSERTAR', {
      par_Nombre: formData.nombre.trim()
    })

    showToast('success', 'Rubro creado exitosamente')
    formData.nombre = ''
    await cargarRubros()
  } catch (error) {
    handleError(error, 'Error al crear rubro')
  } finally {
    loading.value = false
  }
}

const openDocumentation = () => {
  showDocumentation.value = true
}

const closeDocumentation = () => {
  showDocumentation.value = false
}

const goBack = () => {
  router.push('/otras_obligaciones')
}

onMounted(() => {
  cargarRubros()
})
</script>
