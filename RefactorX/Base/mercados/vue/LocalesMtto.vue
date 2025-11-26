<template>
  <div class="locales-mtto-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Altas de Locales</li>
      </ol>
    </nav>
    <h2>Altas de Locales de Mercados</h2>
    <form @submit.prevent="onBuscar">
      <div class="row">
        <div class="col-md-2">
          <label>Recaudadora</label>
          <select v-model="form.oficina" class="form-control" required @change="cargarMercados">
            <option value="">Seleccione...</option>
            <option v-for="rec in catalogs.recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }} - {{
              rec.recaudadora }}</option>
          </select>
        </div>
        <div class="col-md-3">
          <label>Mercado</label>
          <select v-model="form.num_mercado" class="form-control" required @change="onMercadoChange"
            :disabled="mercados.length === 0">
            <option value="">Seleccione...</option>
            <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
              {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
            </option>
          </select>
        </div>
        <div class="col-md-1">
          <label>Cat.</label>
          <input v-model="form.categoria" type="number" class="form-control" required readonly />
        </div>
        <div class="col-md-2">
          <label>Sección</label>
          <select v-model="form.seccion" class="form-control" required>
            <option value="">Seleccione...</option>
            <option v-for="sec in catalogs.secciones" :key="sec.seccion" :value="sec.seccion">{{ sec.seccion }} - {{
              sec.descripcion }}</option>
          </select>
        </div>
        <div class="col-md-1">
          <label>Local</label>
          <input v-model="form.local" type="number" class="form-control" required />
        </div>
        <div class="col-md-1">
          <label>Letra</label>
          <input v-model="form.letra_local" type="text" maxlength="1" class="form-control" />
        </div>
        <div class="col-md-1">
          <label>Bloque</label>
          <input v-model="form.bloque" type="text" maxlength="1" class="form-control" />
        </div>
        <div class="col-md-2 d-flex align-items-end">
          <button type="submit" class="btn btn-primary">Buscar</button>
        </div>
      </div>
    </form>
    <div v-if="busquedaRealizada">
      <div v-if="localExiste" class="alert alert-danger mt-3">El local ya existe. Verifique los datos.</div>
      <div v-else class="mt-3">
        <form @submit.prevent="onAltaLocal">
          <div class="row">
            <div class="col-md-3">
              <label>Nombre</label>
              <input v-model="form.nombre" type="text" class="form-control" required />
            </div>
            <div class="col-md-2">
              <label>Giro</label>
              <input v-model="form.giro" type="number" class="form-control" required min="1" />
            </div>
            <div class="col-md-2">
              <label>Sector</label>
              <select v-model="form.sector" class="form-control" required>
                <option value="J">J</option>
                <option value="R">R</option>
                <option value="L">L</option>
                <option value="H">H</option>
              </select>
            </div>
            <div class="col-md-3">
              <label>Domicilio</label>
              <input v-model="form.domicilio" type="text" class="form-control" />
            </div>
            <div class="col-md-2">
              <label>Superficie</label>
              <input v-model="form.superficie" type="number" step="0.01" class="form-control" required min="0.01" />
            </div>
          </div>
          <div class="row mt-2">
            <div class="col-md-3">
              <label>Descripción Local</label>
              <input v-model="form.descripcion_local" type="text" class="form-control" />
            </div>
            <div class="col-md-2">
              <label>Zona</label>
              <select v-model="form.zona" class="form-control" required>
                <option v-for="zona in catalogs.zonas" :key="zona.id_zona" :value="zona.id_zona">{{ zona.id_zona }} - {{
                  zona.zona }}</option>
              </select>
            </div>
            <div class="col-md-2">
              <label>Clave Cuota</label>
              <select v-model="form.clave_cuota" class="form-control" required>
                <option v-for="cuota in catalogs.cuotas" :key="cuota.clave_cuota" :value="cuota.clave_cuota">{{
                  cuota.clave_cuota }} - {{ cuota.descripcion }}</option>
              </select>
            </div>
            <div class="col-md-2">
              <label>Fecha Alta</label>
              <input v-model="form.fecha_alta" type="date" class="form-control" required />
            </div>
            <div class="col-md-2">
              <label>Número Memo</label>
              <input v-model="form.numero_memo" type="number" class="form-control" required min="1" />
            </div>
            <div class="col-md-1 d-flex align-items-end">
              <button type="submit" class="btn btn-success">Alta Local</button>
            </div>
          </div>
        </form>
        <div v-if="altaSuccess" class="alert alert-success mt-3">El local se dio de alta correctamente.</div>
        <div v-if="altaError" class="alert alert-danger mt-3">{{ altaError }}</div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'LocalesMttoPage',
  data() {
    return {
      catalogs: {
        recaudadoras: [],
        secciones: [],
        zonas: [],
        cuotas: []
      },
      mercados: [],
      form: {
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
        id_usuario: 1, // Simulación, debe venir del login
        axo: new Date().getFullYear()
      },
      busquedaRealizada: false,
      localExiste: false,
      altaSuccess: false,
      altaError: ''
    };
  },
  created() {
    this.loadCatalogs();
  },
  methods: {
    async loadCatalogs() {
      const resp = await axios.post('/api/execute', { action: 'get_catalogs' });
      if (resp.data.success) {
        this.catalogs = resp.data.data;
      }
    },
    async cargarMercados() {
      this.form.num_mercado = '';
      this.form.categoria = '';
      this.mercados = [];

      if (!this.form.oficina) return;

      try {
        const resp = await axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_consulta_locales_get_mercados',
            Base: 'padron_licencias',
            Parametros: [
              { Nombre: 'p_oficina', Valor: parseInt(this.form.oficina) }
            ]
          }
        });

        if (resp.data.eResponse?.success && resp.data.eResponse?.data) {
          this.mercados = resp.data.eResponse.data.result || [];
        }
      } catch (error) {
        console.error('Error al cargar mercados:', error);
        this.mercados = [];
      }
    },
    onMercadoChange() {
      const selected = this.mercados.find(m => m.num_mercado_nvo == this.form.num_mercado);
      if (selected) {
        this.form.categoria = selected.categoria;
      }
    },
    async onBuscar() {
      this.busquedaRealizada = false;
      this.localExiste = false;
      this.altaSuccess = false;
      this.altaError = '';
      // Buscar si existe el local
      const params = {
        oficina: this.form.oficina,
        num_mercado: this.form.num_mercado,
        categoria: this.form.categoria,
        seccion: this.form.seccion,
        local: this.form.local,
        letra_local: this.form.letra_local,
        bloque: this.form.bloque
      };
      const resp = await axios.post('/api/execute', { action: 'buscar_local', params });
      this.busquedaRealizada = true;
      if (resp.data.success && resp.data.data && resp.data.data.length > 0) {
        this.localExiste = true;
      } else {
        this.localExiste = false;
      }
    },
    async onAltaLocal() {
      this.altaSuccess = false;
      this.altaError = '';
      const params = { ...this.form };
      const resp = await axios.post('/api/execute', { action: 'alta_local', params });
      if (resp.data.success) {
        this.altaSuccess = true;
        this.busquedaRealizada = false;
        // Limpiar formulario
        Object.keys(this.form).forEach(k => {
          if (typeof this.form[k] === 'string') this.form[k] = '';
        });
        this.form.vigencia = 'A';
        this.form.id_usuario = 1;
        this.form.axo = new Date().getFullYear();
      } else {
        this.altaError = resp.data.message || 'Error al dar de alta el local';
      }
    }
  }
};
</script>

<style scoped>
.locales-mtto-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
