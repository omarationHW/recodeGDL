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
                <select v-model="formBuscar.oficina" class="municipal-form-control" required>
                  <option value="">Seleccione...</option>
                  <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                    {{ rec.id_rec }}
                  </option>
                </select>
              </div>

              <div class="form-group" style="flex: 0 0 15%;">
                <label class="municipal-form-label">Mercado</label>
                <input type="number" v-model.number="formBuscar.num_mercado" class="municipal-form-control" required
                  min="1" />
              </div>

              <div class="form-group" style="flex: 0 0 15%;">
                <label class="municipal-form-label">Categoría</label>
                <input type="number" v-model.number="formBuscar.categoria" class="municipal-form-control" required
                  min="1" />
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
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { useToast } from 'vue-toastification'

const toast = useToast()

// Estado reactivo
const recaudadoras = ref([])
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
onMounted(() => {
  fetchRecaudadoras()
  fetchSecciones()
})

// Cargar catálogo de recaudadoras
const fetchRecaudadoras = async () => {
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'padron_licencias',
        Parametros: []
      }
    })

    // La API devuelve los datos en eResponse.data.result
    const apiResponse = response.data.eResponse || response.data
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
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_catalogo_secciones',
        Base: 'mercados',
        Parametros: []
      }
    })

    // La API devuelve los datos en eResponse.data.result
    const apiResponse = response.data.eResponse || response.data
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

// Buscar energía del local
const buscarEnergia = async () => {
  if (!formBuscar.value.movimiento) {
    toast.warning('Debe seleccionar el tipo de movimiento')
    return
  }

  loading.value = true
  energia.value = null

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_energia_modif_buscar',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(formBuscar.value.oficina) },
          { Nombre: 'p_num_mercado', Valor: parseInt(formBuscar.value.num_mercado) },
          { Nombre: 'p_categoria', Valor: parseInt(formBuscar.value.categoria) },
          { Nombre: 'p_seccion', Valor: formBuscar.value.seccion },
          { Nombre: 'p_local', Valor: parseInt(formBuscar.value.local) },
          { Nombre: 'p_letra_local', Valor: formBuscar.value.letra_local || null },
          { Nombre: 'p_bloque', Valor: formBuscar.value.bloque || null }
        ]
      }
    })

    // La API devuelve los datos en eResponse.data.result
    const apiResponse = response.data.eResponse || response.data
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
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_energia_modif_modificar',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_id_energia', Valor: parseInt(energia.value.id_energia) },
          { Nombre: 'p_id_local', Valor: parseInt(energia.value.id_local) },
          { Nombre: 'p_cantidad', Valor: parseFloat(energia.value.cantidad) },
          { Nombre: 'p_vigencia', Valor: energia.value.vigencia },
          { Nombre: 'p_fecha_alta', Valor: energia.value.fecha_alta },
          { Nombre: 'p_fecha_baja', Valor: energia.value.fecha_baja || null },
          { Nombre: 'p_movimiento', Valor: formBuscar.value.movimiento },
          { Nombre: 'p_cve_consumo', Valor: energia.value.cve_consumo },
          { Nombre: 'p_local_adicional', Valor: energia.value.local_adicional || null },
          { Nombre: 'p_usuario_id', Valor: 1 }, // TODO: obtener usuario real
          { Nombre: 'p_periodo_baja_axo', Valor: ['B', 'D'].includes(formBuscar.value.movimiento) ? periodoBaja.value.axo : null },
          { Nombre: 'p_periodo_baja_mes', Valor: ['B', 'D'].includes(formBuscar.value.movimiento) ? periodoBaja.value.mes : null }
        ]
      }
    })

    // La API devuelve los datos en eResponse.data.result
    const apiResponse = response.data.eResponse || response.data
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

<style src="@/styles/municipal-theme.css"></style>
