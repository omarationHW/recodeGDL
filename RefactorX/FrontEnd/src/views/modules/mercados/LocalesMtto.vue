<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Altas de Locales de Mercados</h1>
        <p>Gestión y registro de nuevos locales en mercados municipales</p>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Formulario de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Búsqueda de Local
          </h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="onBuscar">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Recaudadora</label>
                <select v-model="form.oficina" class="municipal-form-control" required>
                  <option v-for="rec in catalogs.recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                    {{ rec.id_rec }} - {{ rec.recaudadora }}
                  </option>
                </select>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Mercado</label>
                <input v-model="form.num_mercado" type="number" class="municipal-form-control" required />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Categoría</label>
                <input v-model="form.categoria" type="number" class="municipal-form-control" required />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Sección</label>
                <select v-model="form.seccion" class="municipal-form-control" required>
                  <option v-for="sec in catalogs.secciones" :key="sec.seccion" :value="sec.seccion">
                    {{ sec.seccion }} - {{ sec.descripcion }}
                  </option>
                </select>
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Local</label>
                <input v-model="form.local" type="number" class="municipal-form-control" required />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Letra</label>
                <input v-model="form.letra_local" type="text" maxlength="1" class="municipal-form-control" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Bloque</label>
                <input v-model="form.bloque" type="text" maxlength="1" class="municipal-form-control" />
              </div>
            </div>
            <div class="button-group">
              <button type="submit" class="btn-municipal-primary">
                <font-awesome-icon icon="search" />
                Buscar
              </button>
            </div>
          </form>
        </div>
      </div>

      <!-- Resultados de búsqueda -->
      <div v-if="busquedaRealizada">
        <div v-if="localExiste" class="municipal-card">
          <div class="municipal-card-body">
            <div class="alert-message alert-danger">
              <font-awesome-icon icon="exclamation-triangle" />
              El local ya existe. Verifique los datos.
            </div>
          </div>
        </div>

        <!-- Formulario de alta de local -->
        <div v-else class="municipal-card">
          <div class="municipal-card-header">
            <h5>
              <font-awesome-icon icon="plus-circle" />
              Alta de Nuevo Local
            </h5>
          </div>
          <div class="municipal-card-body">
            <form @submit.prevent="onAltaLocal">
              <div class="form-row">
                <div class="form-group">
                  <label class="municipal-form-label">Nombre</label>
                  <input v-model="form.nombre" type="text" class="municipal-form-control" required />
                </div>
                <div class="form-group">
                  <label class="municipal-form-label">Giro</label>
                  <input v-model="form.giro" type="number" class="municipal-form-control" required min="1" />
                </div>
                <div class="form-group">
                  <label class="municipal-form-label">Sector</label>
                  <select v-model="form.sector" class="municipal-form-control" required>
                    <option value="J">J - Jurídico</option>
                    <option value="R">R - Regular</option>
                    <option value="L">L - Libre</option>
                    <option value="H">H - Histórico</option>
                  </select>
                </div>
                <div class="form-group">
                  <label class="municipal-form-label">Domicilio</label>
                  <input v-model="form.domicilio" type="text" class="municipal-form-control" />
                </div>
              </div>
              <div class="form-row">
                <div class="form-group">
                  <label class="municipal-form-label">Superficie</label>
                  <input v-model="form.superficie" type="number" step="0.01" class="municipal-form-control" required min="0.01" />
                </div>
                <div class="form-group">
                  <label class="municipal-form-label">Descripción Local</label>
                  <input v-model="form.descripcion_local" type="text" class="municipal-form-control" />
                </div>
                <div class="form-group">
                  <label class="municipal-form-label">Zona</label>
                  <select v-model="form.zona" class="municipal-form-control" required>
                    <option v-for="zona in catalogs.zonas" :key="zona.id_zona" :value="zona.id_zona">
                      {{ zona.id_zona }} - {{ zona.zona }}
                    </option>
                  </select>
                </div>
                <div class="form-group">
                  <label class="municipal-form-label">Clave Cuota</label>
                  <select v-model="form.clave_cuota" class="municipal-form-control" required>
                    <option v-for="cuota in catalogs.cuotas" :key="cuota.clave_cuota" :value="cuota.clave_cuota">
                      {{ cuota.clave_cuota }} - {{ cuota.descripcion }}
                    </option>
                  </select>
                </div>
              </div>
              <div class="form-row">
                <div class="form-group">
                  <label class="municipal-form-label">Fecha Alta</label>
                  <input v-model="form.fecha_alta" type="date" class="municipal-form-control" required />
                </div>
                <div class="form-group">
                  <label class="municipal-form-label">Número Memo</label>
                  <input v-model="form.numero_memo" type="number" class="municipal-form-control" required min="1" />
                </div>
              </div>
              <div class="button-group">
                <button type="submit" class="btn-municipal-success">
                  <font-awesome-icon icon="check" />
                  Alta Local
                </button>
              </div>
            </form>

            <div v-if="altaSuccess" class="alert-message alert-success">
              <font-awesome-icon icon="check-circle" />
              El local se dio de alta correctamente.
            </div>
            <div v-if="altaError" class="alert-message alert-danger">
              <font-awesome-icon icon="exclamation-circle" />
              {{ altaError }}
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useToast } from 'vue-toastification'

const { execute } = useApi()
const { handleApiError } = useLicenciasErrorHandler()
const toast = useToast()

const catalogs = ref({
  recaudadoras: [],
  secciones: [],
  zonas: [],
  cuotas: []
})

const form = ref({
  oficina: '',
  num_mercado: '',
  categoria: '',
  seccion: '',
  local: '',
  letra_local: '',
  bloque: '',
  nombre: '',
  giro: '',
  sector: '',
  domicilio: '',
  zona: '',
  descripcion_local: '',
  superficie: '',
  fecha_alta: '',
  clave_cuota: '',
  numero_memo: '',
  vigencia: 'A',
  id_usuario: 1,
  axo: new Date().getFullYear()
})

const busquedaRealizada = ref(false)
const localExiste = ref(false)
const altaSuccess = ref(false)
const altaError = ref('')

const loadCatalogs = async () => {
  try {
    const response = await execute(
      'sp_get_catalogs',
      'mercados',
      [],
      'guadalajara'
    )
    if (response && response.result) {
      catalogs.value = response.result
    }
  } catch (error) {
    handleApiError(error)
    toast.error('Error al cargar catálogos')
  }
}

const onBuscar = async () => {
  busquedaRealizada.value = false
  localExiste.value = false
  altaSuccess.value = false
  altaError.value = ''

  try {
    const response = await execute(
      'sp_buscar_local',
      'mercados',
      [
        { nombre: 'p_oficina', valor: form.value.oficina },
        { nombre: 'p_num_mercado', valor: form.value.num_mercado },
        { nombre: 'p_categoria', valor: form.value.categoria },
        { nombre: 'p_seccion', valor: form.value.seccion },
        { nombre: 'p_local', valor: form.value.local },
        { nombre: 'p_letra_local', valor: form.value.letra_local },
        { nombre: 'p_bloque', valor: form.value.bloque }
      ],
      'guadalajara'
    )

    busquedaRealizada.value = true
    if (response && response.result && response.result.length > 0) {
      localExiste.value = true
      toast.warning('El local ya existe en el sistema')
    } else {
      localExiste.value = false
      toast.info('El local no existe, puede proceder con el alta')
    }
  } catch (error) {
    handleApiError(error)
    toast.error('Error al buscar el local')
  }
}

const onAltaLocal = async () => {
  altaSuccess.value = false
  altaError.value = ''

  try {
    const response = await execute(
      'sp_alta_local',
      'mercados',
      [
        { nombre: 'p_oficina', valor: form.value.oficina },
        { nombre: 'p_num_mercado', valor: form.value.num_mercado },
        { nombre: 'p_categoria', valor: form.value.categoria },
        { nombre: 'p_seccion', valor: form.value.seccion },
        { nombre: 'p_local', valor: form.value.local },
        { nombre: 'p_letra_local', valor: form.value.letra_local },
        { nombre: 'p_bloque', valor: form.value.bloque },
        { nombre: 'p_nombre', valor: form.value.nombre },
        { nombre: 'p_giro', valor: form.value.giro },
        { nombre: 'p_sector', valor: form.value.sector },
        { nombre: 'p_domicilio', valor: form.value.domicilio },
        { nombre: 'p_zona', valor: form.value.zona },
        { nombre: 'p_descripcion_local', valor: form.value.descripcion_local },
        { nombre: 'p_superficie', valor: form.value.superficie },
        { nombre: 'p_fecha_alta', valor: form.value.fecha_alta },
        { nombre: 'p_clave_cuota', valor: form.value.clave_cuota },
        { nombre: 'p_numero_memo', valor: form.value.numero_memo },
        { nombre: 'p_vigencia', valor: form.value.vigencia },
        { nombre: 'p_id_usuario', valor: form.value.id_usuario },
        { nombre: 'p_axo', valor: form.value.axo }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      altaSuccess.value = true
      toast.success('Local dado de alta correctamente')
      busquedaRealizada.value = false

      // Limpiar formulario
      Object.keys(form.value).forEach(k => {
        if (typeof form.value[k] === 'string') form.value[k] = ''
      })
      form.value.vigencia = 'A'
      form.value.id_usuario = 1
      form.value.axo = new Date().getFullYear()
    }
  } catch (error) {
    handleApiError(error)
    altaError.value = error.message || 'Error al dar de alta el local'
    toast.error('Error al dar de alta el local')
  }
}

onMounted(() => {
  loadCatalogs()
})
</script>
