<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="edit" />
      </div>
      <div class="module-view-info">
        <h1>Modificación de Locales</h1>
        <p>Inicio > Mercados > Modificación de Locales</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card mb-3">
        <div class="municipal-card-header">
          <h5>Búsqueda de Local</h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="onBuscar">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Recaudadora <span class="required">*</span></label>
                <select v-model="form.oficina" class="municipal-form-control" required :disabled="loading"
                  @change="onRecChange">
                  <option value="">Seleccione...</option>
                  <option v-for="z in catalogos.recaudadoras" :key="z.id_rec" :value="z.id_rec">
                    {{ z.id_rec }} - {{ z.recaudadora }}
                  </option>
                </select>
              </div>
              <div class="form-group" style="flex: 2;">
                <label class="municipal-form-label">Mercado <span class="required">*</span></label>
                <select v-model.number="form.num_mercado" class="municipal-form-control" required
                  :disabled="!form.oficina || loading" @change="onMercadoChange">
                  <option value="">Seleccione...</option>
                  <option v-for="m in catalogos.mercados" :key="m.num_mercado_nvo" :value="m.num_mercado_nvo">
                    {{ m.num_mercado_nvo }} - {{ m.descripcion }}
                  </option>
                </select>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Cat. <span class="required">*</span></label>
                <select v-model.number="form.categoria" class="municipal-form-control" disabled
                  style="background-color: #f0f0f0; cursor: not-allowed;">
                  <option value="">-</option>
                  <option v-for="c in catalogos.categorias" :key="c.categoria" :value="c.categoria">
                    {{ c.categoria }} - {{ c.descripcion }}
                  </option>
                </select>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Sección <span class="required">*</span></label>
                <select v-model="form.seccion" class="municipal-form-control" required :disabled="loading">
                  <option value="">Seleccione...</option>
                  <option v-for="s in catalogos.secciones" :key="s.seccion" :value="s.seccion">{{ s.seccion }}</option>
                </select>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Local <span class="required">*</span></label>
                <input v-model.number="form.local" type="number" class="municipal-form-control" required
                  :disabled="loading" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Letra</label>
                <input v-model="form.letra_local" type="text" class="municipal-form-control" maxlength="1"
                  :disabled="loading" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Bloque</label>
                <input v-model="form.bloque" type="text" class="municipal-form-control" maxlength="1"
                  :disabled="loading" />
              </div>
            </div>

            <div class="row mt-3">
              <div class="col-12">
                <div class="text-end">
                  <button type="submit" class="btn-municipal-primary" :disabled="loading">
                    <font-awesome-icon icon="search" />
                    Buscar
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>

      <div v-if="loading" class="text-center py-4">
        <div class="spinner-border text-primary" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
      </div>

      <div v-if="local" class="municipal-card mb-3">
        <div class="municipal-card-header">
          <h5>Datos del Local</h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="onModificar">
            <div class="row">
              <div class="col-md-6 mb-3">
                <label class="municipal-form-label">Nombre *</label>
                <input v-model="local.nombre" class="municipal-form-control" required maxlength="60"
                  :disabled="loading" />
              </div>
              <div class="col-md-6 mb-3">
                <label class="municipal-form-label">Domicilio</label>
                <input v-model="local.domicilio" class="municipal-form-control" maxlength="40" :disabled="loading" />
              </div>
            </div>
            <div class="row">
              <div class="col-md-3 mb-3">
                <label class="municipal-form-label">Sector *</label>
                <select v-model="local.sector" class="municipal-form-control" required :disabled="loading">
                  <option value="">Seleccione...</option>
                  <option v-for="s in catalogos.sectores" :key="s.clave" :value="s.clave">{{ s.descripcion }}</option>
                </select>
              </div>
              <div class="col-md-3 mb-3">
                <label class="municipal-form-label">Zona *</label>
                <select v-model="local.zona" class="municipal-form-control" required :disabled="loading">
                  <option value="">Seleccione...</option>
                  <option v-for="z in catalogos.zonas" :key="z.id_zona" :value="z.id_zona">{{ z.id_zona }} - {{ z.zona }}
                  </option>
                </select>
              </div>
              <div class="col-md-3 mb-3">
                <label class="municipal-form-label">Descripción</label>
                <input v-model="local.descripcion_local" class="municipal-form-control" maxlength="20"
                  :disabled="loading" />
              </div>
              <div class="col-md-3 mb-3">
                <label class="municipal-form-label">Superficie *</label>
                <input v-model.number="local.superficie" type="number" step="0.01" class="municipal-form-control"
                  required :disabled="loading" />
              </div>
            </div>
            <div class="row">
              <div class="col-md-3 mb-3">
                <label class="municipal-form-label">Giro *</label>
                <select v-model="local.giro" class="municipal-form-control" required :disabled="loading">
                  <option value="">Seleccione...</option>
                  <option v-for="g in catalogos.giros" :key="g.id_giro" :value="g.id_giro">
                    {{ g.id_giro }} - {{ g.descripcion }}
                  </option>
                </select>
              </div>
              <div class="col-md-3 mb-3">
                <label class="municipal-form-label">Fecha Alta *</label>
                <input v-model="local.fecha_alta" type="date" class="municipal-form-control" required
                  :disabled="loading" />
              </div>
              <div class="col-md-3 mb-3">
                <label class="municipal-form-label">Fecha Baja</label>
                <input v-model="local.fecha_baja" type="date" class="municipal-form-control" :disabled="loading" />
              </div>
              <div class="col-md-3 mb-3">
                <label class="municipal-form-label">Vigencia *</label>
                <select v-model="local.vigencia" class="municipal-form-control" required :disabled="loading">
                  <option value="">Seleccione...</option>
                  <option value="A">VIGENTE</option>
                  <option value="B">BAJA</option>
                  <option value="C">BAJA POR ACUERDO</option>
                  <option value="D">BAJA ADMINISTRATIVA</option>
                </select>
              </div>
            </div>
            <div class="row">
              <div class="col-md-4 mb-3">
                <label class="municipal-form-label">Clave Cuota *</label>
                <select v-model="local.clave_cuota" class="municipal-form-control" required :disabled="loading">
                  <option value="">Seleccione...</option>
                  <option v-for="c in catalogos.cuotas" :key="c.clave_cuota" :value="c.clave_cuota">
                    {{ c.clave_cuota }} - {{ c.descripcion }}
                  </option>
                </select>
              </div>
              <div class="col-md-4 mb-3">
                <label class="municipal-form-label">Movimiento *</label>
                <select v-model="local.tipo_movimiento" class="municipal-form-control" required :disabled="loading">
                  <option value="">Seleccione...</option>
                  <option v-for="m in catalogos.movimientos" :key="m.clave_movimiento" :value="m.clave_movimiento">
                    {{ m.clave_movimiento }} - {{ m.descripcion }}
                  </option>
                </select>
              </div>
              <div class="col-md-4 mb-3">
                <label class="municipal-form-label">Bloqueo</label>
                <select v-model="local.bloqueo" class="municipal-form-control" :disabled="loading">
                  <option value="">Seleccione...</option>
                  <option value="0">Sin bloqueo</option>
                  <option v-for="b in catalogos.bloqueos" :key="b.cve_bloqueo" :value="b.cve_bloqueo">
                    {{ b.cve_bloqueo }} - {{ b.descripcion }}
                  </option>
                </select>
              </div>
            </div>
            <div v-if="local.tipo_movimiento == 12 || local.tipo_movimiento == 13" class="row">
              <div class="col-md-4 mb-3">
                <label class="municipal-form-label">Clave Bloqueo</label>
                <select v-model="local.cve_bloqueo" class="municipal-form-control" :disabled="loading">
                  <option value="">Seleccione...</option>
                  <option v-for="b in catalogos.bloqueos" :key="b.cve_bloqueo" :value="b.cve_bloqueo">
                    {{ b.cve_bloqueo }} - {{ b.descripcion }}
                  </option>
                </select>
              </div>
              <div v-if="local.tipo_movimiento == 12" class="col-md-4 mb-3">
                <label class="municipal-form-label">Fecha Inicio Bloqueo</label>
                <input v-model="local.fecha_inicio_bloqueo" type="date" class="municipal-form-control"
                  :disabled="loading" />
              </div>
              <div v-if="local.tipo_movimiento == 13" class="col-md-4 mb-3">
                <label class="municipal-form-label">Fecha Final Bloqueo</label>
                <input v-model="local.fecha_final_bloqueo" type="date" class="municipal-form-control"
                  :disabled="loading" />
              </div>
              <div class="col-md-12 mb-3">
                <label class="municipal-form-label">Observación</label>
                <input v-model="local.observacion" class="municipal-form-control" maxlength="250" :disabled="loading" />
              </div>
            </div>
            <div class="d-flex justify-content-end">
              <button type="submit" class="btn-municipal-success" :disabled="loading">
                <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
                Modificar Local
              </button>
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
const loading = ref(false)
const local = ref(null)

const form = ref({
  oficina: '',
  num_mercado: '',
  categoria: '',
  seccion: '',
  local: '',
  letra_local: '',
  bloque: ''
})

const catalogos = ref({
  zonas: [],
  cuotas: [],
  sectores: [],
  movimientos: [],
  bloqueos: [],
  recaudadoras: [],
  mercados: [],
  secciones: [],
  giros: [],
  categorias: []
})

const loadCatalogos = async () => {
  loading.value = true
  try {
    // Cargar recaudadoras - Base: padron_licencias
    const recRes = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'padron_licencias',
        Parametros: []
      }
    })
    if (recRes.data?.eResponse?.success) {
      catalogos.value.recaudadoras = recRes.data.eResponse.data.result || []
    }

    // Cargar secciones - Base: padron_licencias
    const secRes = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_secciones',
        Base: 'padron_licencias',
        Parametros: []
      }
    })
    if (secRes.data?.eResponse?.success) {
      catalogos.value.secciones = secRes.data.eResponse.data.result || []
    }

    // Cargar giros - Base: padron_licencias
    const girosRes = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_giros_vigentes',
        Base: 'padron_licencias',
        Parametros: []
      }
    })
    if (girosRes.data?.eResponse?.success) {
      catalogos.value.giros = girosRes.data.eResponse.data.result || []
    }

    // Cargar categorías - Base: mercados
    const catRes = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_categoria_list',
        Base: 'mercados',
        Parametros: []
      }
    })
    if (catRes.data?.eResponse?.success) {
      catalogos.value.categorias = catRes.data.eResponse.data.result || []
    }

    // Cargar cuotas - Base: padron_licencias
    const cuoRes = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cve_cuota_list',
        Base: 'padron_licencias',
        Parametros: []
      }
    })
    if (cuoRes.data?.eResponse?.success) {
      catalogos.value.cuotas = cuoRes.data.eResponse.data.result || []
    }

    // Cargar zonas - Base: padron_licencias
    const zonRes = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_zonas',
        Base: 'padron_licencias',
        Parametros: []
      }
    })
    if (zonRes.data?.eResponse?.success) {
      catalogos.value.zonas = zonRes.data.eResponse.data.result || []
    }

    // Cargar sectores - Base: mercados
    const sectoresRes = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_catalogo_secciones',
        Base: 'mercados',
        Parametros: []
      }
    })
    if (sectoresRes.data?.eResponse?.success) {
      catalogos.value.sectores = sectoresRes.data.eResponse.data.result || []
    }

    // Cargar movimientos - Base: mercados
    const movRes = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_movimientos',
        Base: 'mercados',
        Parametros: []
      }
    })
    if (movRes.data?.eResponse?.success) {
      catalogos.value.movimientos = movRes.data.eResponse.data.result || []
    }

    // Cargar bloqueos - Base: mercados
    const blqRes = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_bloqueos',
        Base: 'mercados',
        Parametros: []
      }
    })
    if (blqRes.data?.eResponse?.success) {
      catalogos.value.bloqueos = blqRes.data.eResponse.data.result || []
    }
  } catch (error) {
    toast.error('Error al cargar catálogos')
    console.error('Error:', error)
  } finally {
    loading.value = false
  }
}

const onRecChange = async () => {
  // Limpiar mercado y categoría al cambiar recaudadora
  form.value.num_mercado = ''
  form.value.categoria = ''
  catalogos.value.mercados = []

  if (!form.value.oficina) return

  // Cargar mercados
  try {
    const nivelUsuario = 1 // Usuario con acceso completo
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_catalogo_mercados',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(form.value.oficina) },
          { Nombre: 'p_nivel_usuario', Valor: nivelUsuario }
        ]
      }
    })

    if (res.data?.eResponse?.success) {
      catalogos.value.mercados = res.data.eResponse.data.result || []
    }
  } catch (error) {
    console.error('Error al cargar mercados:', error)
    toast.error('Error al cargar mercados')
  }
}

const onMercadoChange = () => {
  // Auto-asignar categoría basada en el mercado seleccionado
  const selected = catalogos.value.mercados.find(m => m.num_mercado_nvo == form.value.num_mercado)

  if (selected && selected.categoria) {
    form.value.categoria = selected.categoria
  } else {
    form.value.categoria = ''
  }
}

const onBuscar = async () => {
  loading.value = true
  local.value = null
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_localesmodif_buscar_local',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(form.value.oficina) },
          { Nombre: 'p_num_mercado', Valor: parseInt(form.value.num_mercado) },
          { Nombre: 'p_categoria', Valor: parseInt(form.value.categoria) },
          { Nombre: 'p_seccion', Valor: form.value.seccion },
          { Nombre: 'p_local', Valor: parseInt(form.value.local) },
          { Nombre: 'p_letra_local', Valor: form.value.letra_local || '' },
          { Nombre: 'p_bloque', Valor: form.value.bloque || '' }
        ]
      }
    })

    if (response.data?.eResponse?.success && response.data.eResponse.data?.result && response.data.eResponse.data.result.length > 0) {
      local.value = response.data.eResponse.data.result[0]
      toast.success('Local encontrado')
    } else {
      toast.warning('No se encontraron resultados para la búsqueda especificada. Verifique los datos ingresados.')
    }
  } catch (error) {
    toast.error('Error al buscar local')
    console.error('Error:', error)
  } finally {
    loading.value = false
  }
}

const onModificar = async () => {
  loading.value = true
  try {
    console.log('Modificando local con datos:', JSON.stringify(local.value, 2, null))
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_localesmodif_modificar_local',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_id_local', Valor: local.value.id_local },
          { Nombre: 'p_nombre', Valor: local.value.nombre },
          { Nombre: 'p_domicilio', Valor: local.value.domicilio || '' },
          { Nombre: 'p_sector', Valor: local.value.sector },
          { Nombre: 'p_zona', Valor: parseInt(local.value.zona) },
          { Nombre: 'p_descripcion_local', Valor: local.value.descripcion_local || '' },
          { Nombre: 'p_superficie', Valor: parseFloat(local.value.superficie) },
          { Nombre: 'p_giro', Valor: parseInt(local.value.giro) || 0 },
          { Nombre: 'p_fecha_alta', Valor: local.value.fecha_alta },
          { Nombre: 'p_fecha_baja', Valor: local.value.fecha_baja || null },
          { Nombre: 'p_vigencia', Valor: local.value.vigencia },
          { Nombre: 'p_clave_cuota', Valor: local.value.clave_cuota },
          { Nombre: 'p_tipo_movimiento', Valor: parseInt(local.value.tipo_movimiento) },
          { Nombre: 'p_bloqueo', Valor: parseInt(local.value.bloqueo || 0) },
          { Nombre: 'p_cve_bloqueo', Valor: local.value.cve_bloqueo || null },
          { Nombre: 'p_fecha_inicio_bloqueo', Valor: local.value.fecha_inicio_bloqueo || null },
          { Nombre: 'p_fecha_final_bloqueo', Valor: local.value.fecha_final_bloqueo || null },
          { Nombre: 'p_observacion', Valor: local.value.observacion || '' }
        ]
      }
    })

    if (response.data?.eResponse?.success) {
      toast.success('Local modificado correctamente')
    } else {
      toast.error(response.data?.eResponse?.message || 'Error al modificar local')
    }
  } catch (error) {
    toast.error('Error al modificar local')
    console.error('Error:', error)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadCatalogos()
})
</script>

<style scoped>
.required {
  color: #dc3545;
}
</style>
