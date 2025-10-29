<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="bolt" /></div>
      <div class="module-view-info">
        <h1>Alta de Locales para Energía Eléctrica</h1>
        <p>Mercados - Alta de Locales para Energía Eléctrica</p>
      </div>
    </div>

    <div class="module-view-content">
    <h2>Alta de Locales para Energía Eléctrica</h2>
    <form @submit.prevent="onBuscarLocal">
      <div class="row">
        <div class="col-md-2">
          <label>Recaudadora</label>
          <select v-model="form.oficina" class="municipal-form-control" required>
            <option v-for="rec in catalogs.recaudadoras" :key="rec.id" :value="rec.id">{{ rec.nombre }}</option>
          </select>
        </div>
        <div class="col-md-2">
          <label>Mercado</label>
          <select v-model="form.num_mercado" class="municipal-form-control" required>
            <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">{{ merc.descripcion }}</option>
          </select>
        </div>
        <div class="col-md-1">
          <label>Cat.</label>
          <input v-model="form.categoria" class="municipal-form-control" required maxlength="1" />
        </div>
        <div class="col-md-2">
          <label>Sección</label>
          <select v-model="form.seccion" class="municipal-form-control" required>
            <option v-for="sec in catalogs.secciones" :key="sec.id" :value="sec.id">{{ sec.descripcion }}</option>
          </select>
        </div>
        <div class="col-md-1">
          <label>Local</label>
          <input v-model="form.local" class="municipal-form-control" required />
        </div>
        <div class="col-md-1">
          <label>Letra</label>
          <input v-model="form.letra_local" class="municipal-form-control" maxlength="1" />
        </div>
        <div class="col-md-1">
          <label>Bloque</label>
          <input v-model="form.bloque" class="municipal-form-control" maxlength="1" />
        </div>
        <div class="col-md-2 d-flex align-items-end">
          <button class="btn-municipal-primary" type="submit">Buscar Local</button>
        </div>
      </div>
    </form>

    <div v-if="localEncontrado">
      <form @submit.prevent="onAltaEnergiaMtto">
        <div class="row mt-4">
          <div class="col-md-2">
            <label>Clave Consumo</label>
            <select v-model="form.cve_consumo" class="municipal-form-control" required>
              <option v-for="c in catalogs.consumos" :key="c.value" :value="c.value">{{ c.label }}</option>
            </select>
          </div>
          <div class="col-md-3">
            <label>Descripción Local</label>
            <input v-model="form.descripcion" class="municipal-form-control" maxlength="50" required />
          </div>
          <div class="col-md-2">
            <label>Cantidad Mes</label>
            <input v-model="form.cantidad" class="municipal-form-control" type="number" min="0" step="0.01" required />
          </div>
          <div class="col-md-2">
            <label>Vigencia</label>
            <select v-model="form.vigencia" class="municipal-form-control" required>
              <option value="A">Vigente</option>
              <option value="E">Vigente para Emisión</option>
            </select>
          </div>
          <div class="col-md-2">
            <label>Fecha Alta</label>
            <input v-model="form.fecha_alta" class="municipal-form-control" type="date" required />
          </div>
        </div>
        <div class="row mt-3">
          <div class="col-md-2">
            <label>Año</label>
            <input v-model="form.axo" class="municipal-form-control" type="number" required />
          </div>
          <div class="col-md-2">
            <label>Número Oficio</label>
            <input v-model="form.numero" class="municipal-form-control" required />
          </div>
          <div class="col-md-2 d-flex align-items-end">
            <button class="btn-municipal-success" type="submit">Grabar</button>
          </div>
        </div>
      </form>
    </div>

    <div v-if="alert.message" :class="['alert', alert.success ? 'alert-success' : 'alert-danger']" role="alert">
      {{ alert.message }}
    </div>
  </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'EnergiaMttoPage',
  data() {
    return {
      catalogs: {
        recaudadoras: [],
        secciones: [],
        consumos: []
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
        cve_consumo: 'F',
        descripcion: '',
        cantidad: '',
        vigencia: 'A',
        fecha_alta: '',
        axo: '',
        numero: ''
      },
      localEncontrado: false,
      alert: {
        message: '',
        success: false
      }
    };
  },
  created() {
    this.loadCatalogs();
  },
  watch: {
    'form.oficina'(val) {
      if (val) this.loadMercados(val);
    }
  },
  methods: {
    async loadCatalogs() {
      const res = await axios.post('/api/execute', {
        eRequest: { action: 'get_catalogs' }
      });
      if (res.data.eResponse.success) {
        this.catalogs = res.data.eResponse.data;
      }
    },
    async loadMercados(oficina) {
      const res = await axios.post('/api/execute', {
        eRequest: { action: 'catalog_mercados', params: { oficina } }
      });
      if (res.data.eResponse.success) {
        this.mercados = res.data.eResponse.data;
      }
    },
    async onBuscarLocal() {
      this.alert.message = '';
      const params = {
        oficina: this.form.oficina,
        num_mercado: this.form.num_mercado,
        categoria: this.form.categoria,
        seccion: this.form.seccion,
        local: this.form.local,
        letra_local: this.form.letra_local,
        bloque: this.form.bloque
      };
      const res = await axios.post('/api/execute', {
        eRequest: { action: 'buscar_local', params }
      });
      if (res.data.eResponse.success && res.data.eResponse.data.length > 0) {
        this.localEncontrado = true;
        // Prellenar datos si es necesario
        this.form.id_local = res.data.eResponse.data[0].id_local;
      } else {
        this.localEncontrado = false;
        this.alert = { message: 'No se encontró el local o ya tiene energía registrada.', success: false };
      }
    },
    async onAltaEnergiaMtto() {
      this.alert.message = '';
      const params = {
        id_local: this.form.id_local,
        cve_consumo: this.form.cve_consumo,
        descripcion: this.form.descripcion,
        cantidad: this.form.cantidad,
        vigencia: this.form.vigencia,
        fecha_alta: this.form.fecha_alta,
        axo: this.form.axo,
        numero: this.form.numero,
        user_id: 1, // Debe obtenerse del contexto de usuario autenticado
        oficina: this.form.oficina,
        num_mercado: this.form.num_mercado,
        categoria: this.form.categoria,
        seccion: this.form.seccion
      };
      const res = await axios.post('/api/execute', {
        eRequest: { action: 'alta_energia_mtto', params }
      });
      if (res.data.eResponse.success) {
        this.alert = { message: 'Se grabó correctamente el registro de Energía Eléctrica.', success: true };
        this.localEncontrado = false;
      } else {
        this.alert = { message: res.data.eResponse.message || 'Error al grabar.', success: false };
      }
    }
  }
};
</script>

<style scoped>
.energia-mtto-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
