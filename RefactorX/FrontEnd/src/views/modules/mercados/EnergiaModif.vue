<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="edit" />
      </div>
      <div class="module-view-info">
        <h1>Cambios de Energía Eléctrica</h1>
        <p>Mercados - Modificación de registros de consumo eléctrico</p>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Formulario de Búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Buscar Local
          </h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="buscarEnergia">
            <div class="form-row">
              <div class="form-group" style="flex: 0 0 20%;">
                <label class="municipal-form-label">Recaudadora</label>
                <select v-model="formBuscar.oficina" @change="onRecaudadoraChange" class="municipal-form-control" required>
                  <option value="">Seleccione...</option>
                  <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                   {{ rec.id_rec }} - {{ rec.recaudadora }}
                  </option>
                </select>
              </div>

              <div class="form-group" style="flex: 0 0 15%;">
                <label class="municipal-form-label">Mercado</label>
                <select v-model="formBuscar.num_mercado" @change="onMercadoChange" class="municipal-form-control" required
                  :disabled="!formBuscar.oficina || mercados.length === 0">
                  <option value="">Seleccione...</option>
                  <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                    {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                  </option>
                </select>
              </div>

              <div class="form-group" style="flex: 0 0 15%;">
                <label class="municipal-form-label">Categoría</label>
                <input type="number" v-model.number="formBuscar.categoria" class="municipal-form-control" required
                  min="1" disabled />
              </div>

              <div class="form-group" style="flex: 0 0 15%;">
                <label class="municipal-form-label">Sección</label>
                <select v-model="formBuscar.seccion" class="municipal-form-control" required>
                  <option value="">Seleccione...</option>
                  <option v-for="sec in secciones" :key="sec.clave" :value="sec.clave">
                    {{ sec.clave }} - {{ sec.descripcion }}
                  </option>
                </select>
              </div>

              <div class="form-group" style="flex: 0 0 10%;">
                <label class="municipal-form-label">Local</label>
                <input type="number" v-model.number="formBuscar.local" class="municipal-form-control" required
                  min="1" />
              </div>

              <div class="form-group" style="flex: 0 0 10%;">
                <label class="municipal-form-label">Letra</label>
                <input type="text" v-model="formBuscar.letra_local" class="municipal-form-control" maxlength="1" />
              </div>

              <div class="form-group" style="flex: 0 0 10%;">
                <label class="municipal-form-label">Bloque</label>
                <input type="text" v-model="formBuscar.bloque" class="municipal-form-control" maxlength="1" />
              </div>
            </div>

            <div class="form-row">
              <div class="form-group" style="flex: 0 0 30%;">
                <label class="municipal-form-label">Tipo de Movimiento</label>
                <select v-model="formBuscar.movimiento" class="municipal-form-control" required>
                  <option value="">Seleccione...</option>
                  <option value="A">A - Alta/Cambio</option>
                  <option value="B">B - Baja</option>
                  <option value="C">C - Cambio Simple</option>
                  <option value="D">D - Actualizar desde Periodo</option>
                  <option value="F">F - Recalcular Completo</option>
                </select>
              </div>

              <div class="form-group" style="flex: 0 0 70%;">
                <label class="municipal-form-label">&nbsp;</label>
                <button type="submit" class="btn-municipal-primary" :disabled="loading">
                  <font-awesome-icon icon="search" />
                  <span v-if="loading">Buscando...</span>
                  <span v-else>Buscar Local</span>
                </button>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Formulario de Modificación -->
      <div v-if="energia" class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="bolt" />
            Datos de Energía - Local {{ formBuscar.local }}
          </h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="modificarEnergia">
            <div class="form-row">
              <div class="form-group" style="flex: 0 0 25%;">
                <label class="municipal-form-label">Control Mercado (ID Local)</label>
                <input type="text" v-model="energia.id_local" class="municipal-form-control" disabled />
              </div>

              <div class="form-group" style="flex: 0 0 25%;">
                <label class="municipal-form-label">Control Energía (ID)</label>
                <input type="text" v-model="energia.id_energia" class="municipal-form-control" disabled />
              </div>

              <div class="form-group" style="flex: 0 0 25%;">
                <label class="municipal-form-label">Clave de Consumo</label>
                <select v-model="energia.cve_consumo" class="municipal-form-control" required>
                  <option value="A">A - Alta</option>
                  <option value="B">B - Baja</option>
                  <option value="C">C - Cambio</option>
                </select>
              </div>

              <div class="form-group" style="flex: 0 0 25%;">
                <label class="municipal-form-label">Vigencia</label>
                <select v-model="energia.vigencia" class="municipal-form-control" required>
                  <option value="A">A - Activo</option>
                  <option value="B">B - Baja</option>
                  <option value="E">E - En Espera</option>
                </select>
              </div>
            </div>

            <div class="form-row">
              <div class="form-group" style="flex: 0 0 50%;">
                <label class="municipal-form-label">Descripción Local Adicional</label>
                <input type="text" v-model="energia.local_adicional" class="municipal-form-control" maxlength="50" />
              </div>

              <div class="form-group" style="flex: 0 0 25%;">
                <label class="municipal-form-label">Cantidad (Kilowhatts/Cuota)</label>
                <input type="number" v-model.number="energia.cantidad" class="municipal-form-control" required
                  min="0.01" step="0.01" />
              </div>
            </div>

            <div class="form-row">
              <div class="form-group" style="flex: 0 0 25%;">
                <label class="municipal-form-label">Fecha Alta</label>
                <input type="date" v-model="energia.fecha_alta" class="municipal-form-control" required />
              </div>

              <div class="form-group" style="flex: 0 0 25%;">
                <label class="municipal-form-label">Fecha Baja</label>
                <input type="date" v-model="energia.fecha_baja" class="municipal-form-control" />
              </div>
            </div>

            <!-- Campos de Periodo de Baja (solo para movimientos B o D) -->
            <div v-if="['B', 'D'].includes(formBuscar.movimiento)" class="form-row">
              <div class="form-group" style="flex: 0 0 25%;">
                <label class="municipal-form-label">Periodo de Baja - Año</label>
                <input type="number" v-model.number="periodoBaja.axo" class="municipal-form-control" required min="1990"
                  :max="new Date().getFullYear()" />
              </div>

              <div class="form-group" style="flex: 0 0 25%;">
                <label class="municipal-form-label">Periodo de Baja - Mes</label>
                <input type="number" v-model.number="periodoBaja.mes" class="municipal-form-control" required min="1"
                  max="12" />
              </div>
            </div>

            <div class="row mt-3">
              <div class="col-12">
                <div class="button-group">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book-open" />
          <span>Documentacion</span>
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          <span>Ayuda</span>
        </button>
        
                  <button type="submit" class="btn-municipal-purple" :disabled="loading">
                    <font-awesome-icon icon="check-circle" />
                    <span v-if="loading">Modificando...</span>
                    <span v-else>Modificar Registro</span>
                  </button>
                  <button type="button" class="btn-municipal-secondary" @click="cancelar">
                    <font-awesome-icon icon="times" />
                    Cancelar
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>

  <DocumentationModal :show="showAyuda" :component-name="'EnergiaModif'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - EnergiaModif'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'EnergiaModif'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - EnergiaModif'" @close="showDocumentacion = false" />
</template>

<script setup>

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
import Swal from 'sweetalert2';
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { useToast } from 'vue-toastification'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


const toast = useToast()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado reactivo
const recaudadoras = ref([])
const mercados = ref([])
const secciones = ref([])
const energia = ref(null)
const loading = ref(false)

const formBuscar = ref({
  oficina: '',
  num_mercado: '',
  categoria: '',
  seccion: '',
  local: '',
  letra_local: '',
  bloque: '',
  movimiento: ''
})

const periodoBaja = ref({
  axo: new Date().getFullYear(),
  mes: 1
})

// Inicializar

// Ayuda
function mostrarAyuda() {
  Swal.fire({
    title: 'Ayuda - ModificaciÃ³n de EnergÃ­a',
    html: `
      <div style="text-align: left;">
        <h6>Funcionalidad del mÃ³dulo:</h6>
        <p>Este mÃ³dulo permite modificar los registros de energÃ­a elÃ©ctrica.</p>
        <h6>Instrucciones:</h6>
        <ol>
          <li>Busque el local por recaudadora, mercado y nÃºmero de local
          <li>Puede modificar el consumo, vigencia y otros datos
          <li>Los cambios quedan registrados en el historial</li>
        </ol>
      </div>
    `,
    icon: 'info',
    confirmButtonText: 'Entendido'
  });
}

onMounted(async () => {
  showLoading('Cargando Cambios de Energía Eléctrica', 'Preparando catálogos...')
  try {
    await Promise.all([fetchRecaudadoras(), fetchSecciones()])
  } finally {
    hideLoading()
  }
})

// Cargar catálogo de recaudadoras
const fetchRecaudadoras = async () => {
  try {
    const response = await apiService.execute(
          'sp_get_recaudadoras',
          'mercados',
          [],
          '',
          null,
          'publico'
        )

    // La API devuelve los datos en eResponse.data.result
    const apiResponse = response || response.data
    const data = apiResponse.data?.result || apiResponse.data || []

    if (Array.isArray(data) && data.length > 0) {
      recaudadoras.value = data
    } else if (apiResponse.success === false) {
      toast.error(apiResponse.message || 'Error al cargar recaudadoras')
      recaudadoras.value = []
    } else {
      recaudadoras.value = []
    }
  } catch (error) {
    console.error('Error fetchRecaudadoras:', error)
    toast.error('Error al cargar recaudadoras: ' + error.message)
  }
}

// Cargar catálogo de secciones
const fetchSecciones = async () => {
  try {
    const response = await apiService.execute(
          'sp_catalogo_secciones',
          'mercados',
          [],
          '',
          null,
          'publico'
        )

    // La API devuelve los datos en eResponse.data.result
    const apiResponse = response || response.data
    const data = apiResponse.data?.result || apiResponse.data || []

    if (Array.isArray(data) && data.length > 0) {
      secciones.value = data
    } else if (apiResponse.success === false) {
      toast.error(apiResponse.message || 'Error al cargar secciones')
      secciones.value = []
    } else {
      secciones.value = []
    }
  } catch (error) {
    console.error('Error fetchSecciones:', error)
    toast.error('Error al cargar secciones: ' + error.message)
  }
}

// Cuando cambia la recaudadora, cargar mercados
const onRecaudadoraChange = async () => {
  formBuscar.value.num_mercado = ''
  formBuscar.value.categoria = ''
  mercados.value = []

  if (!formBuscar.value.oficina) return

  loading.value = true
  try {
    const response = await apiService.execute(
          'sp_get_catalogo_mercados',
          'mercados',
          [
          { nombre: 'p_id_rec', valor: parseInt(formBuscar.value.oficina) },
          { nombre: 'p_nivel_usuario', valor: 1 }
        ],
          '',
          null,
          'publico'
        )

    // La API devuelve los datos en eResponse.data.result
    const apiResponse = response || response.data
    const data = apiResponse.data?.result || apiResponse.data || []

    if (Array.isArray(data) && data.length > 0) {
      mercados.value = data
    } else if (apiResponse.success === false) {
      toast.error(apiResponse.message || 'Error al cargar mercados')
      mercados.value = []
    } else {
      mercados.value = []
    }
  } catch (error) {
    console.error('Error onRecaudadoraChange:', error)
    toast.error('Error al cargar mercados: ' + error.message)
  } finally {
    loading.value = false
  }
}

// Cuando cambia el mercado, auto-llenar categoría
const onMercadoChange = () => {
  const mercadoSeleccionado = mercados.value.find(m => m.num_mercado_nvo == formBuscar.value.num_mercado)
  if (mercadoSeleccionado) {
    formBuscar.value.categoria = mercadoSeleccionado.categoria
  }
}

// Buscar energía del local
const buscarEnergia = async () => {
  if (!formBuscar.value.movimiento) {
    toast.warning('Debe seleccionar el tipo de movimiento')
    return
  }

  loading.value = true
  energia.value = null

  try {
    const response = await apiService.execute(
          'sp_energia_modif_buscar',
          'mercados',
          [
          { nombre: 'p_oficina', valor: parseInt(formBuscar.value.oficina) },
          { nombre: 'p_num_mercado', valor: parseInt(formBuscar.value.num_mercado) },
          { nombre: 'p_categoria', valor: parseInt(formBuscar.value.categoria) },
          { nombre: 'p_seccion', valor: formBuscar.value.seccion },
          { nombre: 'p_local', valor: parseInt(formBuscar.value.local) },
          { nombre: 'p_letra_local', valor: formBuscar.value.letra_local || null },
          { nombre: 'p_bloque', valor: formBuscar.value.bloque || null }
        ],
          '',
          null,
          'publico'
        )

    // La API devuelve los datos en eResponse.data.result
    const apiResponse = response || response.data
    const data = apiResponse.data?.result || apiResponse.data || []

    if (Array.isArray(data) && data.length > 0) {
      energia.value = { ...data[0] }
      // Formatear fechas para inputs de tipo date
      if (energia.value.fecha_alta) {
        energia.value.fecha_alta = energia.value.fecha_alta.split('T')[0]
      }
      if (energia.value.fecha_baja) {
        energia.value.fecha_baja = energia.value.fecha_baja.split('T')[0]
      }
      toast.success('Registro de energía encontrado')
    } else if (apiResponse.success === false) {
      toast.error(apiResponse.message || 'Error al buscar energía')
    } else {
      toast.warning('No se encontró registro de energía para este local')
    }
  } catch (error) {
    console.error('Error buscarEnergia:', error)
    toast.error('Error al buscar energía: ' + error.message)
  } finally {
    loading.value = false
  }
}

// Modificar energía
const modificarEnergia = async () => {
  loading.value = true

  try {
    const response = await apiService.execute(
          'sp_energia_modif_modificar',
          'mercados',
          [
          { nombre: 'p_id_energia', valor: parseInt(energia.value.id_energia) },
          { nombre: 'p_id_local', valor: parseInt(energia.value.id_local) },
          { nombre: 'p_cantidad', valor: parseFloat(energia.value.cantidad) },
          { nombre: 'p_vigencia', valor: formBuscar.value.movimiento === 'B' ? 'B' : energia.value.vigencia },
          { nombre: 'p_fecha_alta', valor: energia.value.fecha_alta },
          { nombre: 'p_fecha_baja', valor: energia.value.fecha_baja || null },
          { nombre: 'p_movimiento', valor: formBuscar.value.movimiento },
          { nombre: 'p_cve_consumo', valor: energia.value.cve_consumo },
          { nombre: 'p_local_adicional', valor: energia.value.local_adicional || null },
          { nombre: 'p_usuario_id', valor: 1 }, // TODO: obtener usuario real
          { nombre: 'p_periodo_baja_axo', valor: formBuscar.value.movimiento === 'B' ? energia.value.periodo_baja_axo : null }
        ],
        '',
        null,
        'publico'
      )

    // La API devuelve los datos en eResponse.data.result
    const apiResponse = response || response.data
    const data = apiResponse.data?.result || apiResponse.data || []

    if (Array.isArray(data) && data.length > 0) {
      const result = data[0]
      if (result.success || result.success === undefined) {
        toast.success(result.message || 'Energía modificada exitosamente')
        // Limpiar formulario
        energia.value = null
        formBuscar.value = {
          oficina: formBuscar.value.oficina,
          num_mercado: '',
          categoria: '',
          seccion: '',
          local: '',
          letra_local: '',
          bloque: '',
          movimiento: ''
        }
      } else {
        toast.error(result.message || 'Error al modificar energía')
      }
    } else if (apiResponse.success === false) {
      toast.error(apiResponse.message || 'Error al modificar energía')
    } else {
      toast.error('Error al modificar energía')
    }
  } catch (error) {
    console.error('Error modificarEnergia:', error)
    toast.error('Error al modificar energía: ' + error.message)
  } finally {
    loading.value = false
  }
}

// Cancelar modificación
const cancelar = () => {
  energia.value = null
  toast.info('Modificación cancelada')
}
</script>
