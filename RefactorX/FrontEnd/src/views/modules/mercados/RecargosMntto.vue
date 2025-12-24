<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="percentage" />
      </div>
      <div class="module-view-info">
        <h1>Mantenimiento de Recargos</h1>
        <p>Inicio > Catálogos > Recargos</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book-open" />
          <span>Documentacion</span>
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          <span>Ayuda</span>
        </button>
        
        
      </div>
    </div>

    <div class="module-view-content">
      <!-- Formulario -->
      <div class="municipal-card mb-4">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="edit" /> Formulario de Recargos</h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="onSubmit">
            <div class="row">
              <div class="col-md-3 mb-3">
                <label for="axo" class="municipal-form-label">Año <span class="required">*</span></label>
                <input
                  type="number"
                  v-model.number="form.axo"
                  min="1994"
                  max="2999"
                  class="municipal-form-control"
                  id="axo"
                  required
                />
              </div>
              <div class="col-md-3 mb-3">
                <label for="periodo" class="municipal-form-label">Periodo <span class="required">*</span></label>
                <input
                  type="number"
                  v-model.number="form.periodo"
                  min="1"
                  max="12"
                  class="municipal-form-control"
                  id="periodo"
                  required
                />
              </div>
              <div class="col-md-3 mb-3">
                <label for="porcentaje" class="municipal-form-label">Porcentaje <span class="required">*</span></label>
                <input
                  type="number"
                  v-model.number="form.porcentaje"
                  step="0.01"
                  min="0.01"
                  max="99"
                  class="municipal-form-control"
                  id="porcentaje"
                  required
                />
              </div>
            </div>
            <div class="row mt-3">
              <div class="col-12">
                <button type="submit" class="btn-municipal-primary me-2">
                  <font-awesome-icon :icon="editMode ? 'save' : 'plus'" />
                  {{ editMode ? 'Actualizar' : 'Agregar' }}
                </button>
                <button type="button" class="btn-municipal-secondary" @click="resetForm">
                  <font-awesome-icon icon="times" />
                  Cancelar
                </button>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Listado de Recargos -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list" /> Listado de Recargos</h5>
          <div class="header-right">
            <span class="badge-purple" v-if="recargos.length > 0">{{ recargos.length }} registros</span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>#</th>
                  <th>Año</th>
                  <th>Periodo</th>
                  <th>Porcentaje</th>
                  <th>Fecha Alta</th>
                  <th>Usuario</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="recargos.length === 0">
                  <td colspan="7" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No hay recargos registrados.</p>
                  </td>
                </tr>
                <tr v-else v-for="(rec, idx) in recargos" :key="rec.axo + '-' + rec.periodo" class="row-hover">
                  <td class="text-center">{{ idx + 1 }}</td>
                  <td>{{ rec.axo }}</td>
                  <td class="text-center"><span class="badge-primary">{{ rec.periodo }}</span></td>
                  <td>{{ rec.porcentaje }}%</td>
                  <td>{{ formatDate(rec.fecha_alta) }}</td>
                  <td>{{ rec.usuario }}</td>
                  <td class="text-center">
                    <div class="button-group button-group-sm">
                      <button class="btn-municipal-primary btn-sm" @click="editRecargo(rec)" title="Editar">
                        <font-awesome-icon icon="edit" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>

  <DocumentationModal :show="showAyuda" :component-name="'RecargosMntto'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - RecargosMntto'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'RecargosMntto'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - RecargosMntto'" @close="showDocumentacion = false" />
</template>

<script setup>
import Swal from 'sweetalert2'

// Helpers de confirmación SweetAlert
const confirmarAccion = async (titulo, texto, confirmarTexto = 'Sí, continuar') => {
  const result = await Swal.fire({
    title: titulo,
    text: texto,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#3085d6',
    cancelButtonColor: '#d33',
    confirmButtonText: confirmarTexto,
    cancelButtonText: 'Cancelar'
  })
  return result.isConfirmed
}

const mostrarConfirmacionEliminar = async (texto) => {
  const result = await Swal.fire({
    title: '¿Eliminar registro?',
    text: texto,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#d33',
    cancelButtonColor: '#3085d6',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })
  return result.isConfirmed
}
import apiService from '@/services/apiService';
import { ref, onMounted } from 'vue'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


// Composables
const { withLoading } = useGlobalLoading()
const { showToast } = useToast()

// State
const form = ref({
  axo: new Date().getFullYear(),
  periodo: 1,
  porcentaje: null
})

const editMode = ref(false)
const recargos = ref([])
const editingKey = ref(null)

// Funciones
const mostrarAyuda = () => {
  showToast('Administre los porcentajes de recargos por año y periodo. Puede crear o editar recargos.', 'info')
}

const formatDate = (val) => {
  if (!val) return ''
  return new Date(val).toLocaleDateString('es-MX')
}

const fetchRecargos = async () => {
  await withLoading(async () => {
    try {
      const res = await apiService.execute(
        'sp_recargos_ingresos_list',
        'mercados',
        [],
        '',
        null,
        'publico'
      )
      if (res.success) {
        recargos.value = res.data.result || []
      } else {
        showToast(res.message || 'Error al cargar recargos', 'error')
      }
    } catch (error) {
      console.error('Error al cargar recargos:', error)
      showToast('Error al cargar recargos', 'error')
    }
  }, 'Cargando recargos...', 'Por favor espere')
}

const onSubmit = async () => {
  const operation = editMode.value ? 'sp_recargos_update_mercados' : 'sp_recargos_create'

  await withLoading(async () => {
    try {
      const res = await apiService.execute(
        operation,
        'mercados',
        [
          { nombre: 'p_axo', valor: parseInt(form.value.axo), tipo: 'integer' },
          { nombre: 'p_periodo', valor: parseInt(form.value.periodo), tipo: 'integer' },
          { nombre: 'p_porcentaje', valor: parseFloat(form.value.porcentaje), tipo: 'numeric' },
          { nombre: 'p_usuario_id', valor: 1, tipo: 'integer' }
        ],
        '',
        null,
        'publico'
      )

      if (res.success) {
        showToast(
          editMode.value ? 'Recargo actualizado correctamente' : 'Recargo agregado correctamente',
          'success'
        )
        await fetchRecargos()
        resetForm()
      } else {
        showToast(res.message || 'Error al guardar recargo', 'error')
      }
    } catch (error) {
      console.error('Error al guardar recargo:', error)
      showToast('Error al guardar recargo', 'error')
    }
  }, editMode.value ? 'Actualizando recargo...' : 'Agregando recargo...', 'Por favor espere')
}

const editRecargo = (rec) => {
  form.value.axo = rec.axo
  form.value.periodo = rec.periodo
  form.value.porcentaje = rec.porcentaje
  editMode.value = true
  editingKey.value = rec.axo + '-' + rec.periodo
}

const resetForm = () => {
  form.value = {
    axo: new Date().getFullYear(),
    periodo: 1,
    porcentaje: null
  }
  editMode.value = false
  editingKey.value = null
}

// Lifecycle
onMounted(() => {
  fetchRecargos()
})
</script>
