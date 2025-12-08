<template>
  <div class="consulta-general-page">
    <nav class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Consulta General de Locales</span>
    </nav>
    <h1>Consulta General de Locales</h1>
    <form @submit.prevent="buscarLocal">
      <div class="form-row">
        <label>Recaudadora:</label>
        <select v-model="form.oficina" required>
          <option v-for="rec in recaudadoras" :key="rec.id" :value="rec.id">{{ rec.nombre }}</option>
        </select>
        <label>Mercado:</label>
        <input v-model="form.num_mercado" type="number" required />
        <label>Categoria:</label>
        <input v-model="form.categoria" type="number" required />
        <label>Sección:</label>
        <select v-model="form.seccion" required>
          <option v-for="sec in secciones" :key="sec.id" :value="sec.id">{{ sec.nombre }}</option>
        </select>
        <label>Local:</label>
        <input v-model="form.local" type="number" required />
        <label>Letra:</label>
        <input v-model="form.letra_local" maxlength="1" />
        <label>Bloque:</label>
        <input v-model="form.bloque" maxlength="1" />
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="locales.length">
      <h2>Resultados</h2>
      <table class="table table-bordered">
        <thead>
          <tr>
            <th>Control</th>
            <th>Nombre</th>
            <th>Arrendatario</th>
            <th>Domicilio</th>
            <th>Sector</th>
            <th>Zona</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="loc in locales" :key="loc.id_local">
            <td>{{ loc.id_local }}</td>
            <td>{{ loc.nombre }}</td>
            <td>{{ loc.arrendatario }}</td>
            <td>{{ loc.domicilio }}</td>
            <td>{{ loc.sector }}</td>
            <td>{{ loc.zona }}</td>
            <td>
              <button @click="verDetalle(loc.id_local)">Detalle</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="detalle">
      <h2>Detalle del Local</h2>
      <table class="table table-striped">
        <tr><th>Mercado</th><td>{{ detalle.mercado }}</td></tr>
        <tr><th>Control</th><td>{{ detalle.id_local }}</td></tr>
        <tr><th>Nombre</th><td>{{ detalle.nombre }}</td></tr>
        <tr><th>Arrendatario</th><td>{{ detalle.arrendatario }}</td></tr>
        <tr><th>Domicilio</th><td>{{ detalle.domicilio }}</td></tr>
        <tr><th>Sector</th><td>{{ detalle.sector }}</td></tr>
        <tr><th>Zona</th><td>{{ detalle.zona }}</td></tr>
        <tr><th>Descripción</th><td>{{ detalle.descripcion_local }}</td></tr>
        <tr><th>Superficie</th><td>{{ detalle.superficie }}</td></tr>
        <tr><th>Giro</th><td>{{ detalle.giro }}</td></tr>
        <tr><th>Fecha Alta</th><td>{{ detalle.fecha_alta }}</td></tr>
        <tr><th>Fecha Baja</th><td>{{ detalle.fecha_baja }}</td></tr>
        <tr><th>Vigencia</th><td>{{ detalle.vigencia }}</td></tr>
        <tr><th>Usuario</th><td>{{ detalle.usuario }}</td></tr>
        <tr><th>Renta</th><td>{{ detalle.renta }}</td></tr>
      </table>
      <div class="tabs">
        <button :class="{active: tab==='adeudos'}" @click="tab='adeudos'">Adeudos</button>
        <button :class="{active: tab==='pagos'}" @click="tab='pagos'">Pagos</button>
        <button :class="{active: tab==='requerimientos'}" @click="tab='requerimientos'">Requerimientos</button>
      </div>
      <div v-if="tab==='adeudos'">
        <h3>Adeudos</h3>
        <table class="table table-sm">
          <thead><tr><th>Año</th><th>Mes</th><th>Importe</th><th>Recargos</th></tr></thead>
          <tbody>
            <tr v-for="a in adeudos" :key="a.axo+'-'+a.periodo">
              <td>{{ a.axo }}</td><td>{{ a.periodo }}</td><td>{{ a.importe }}</td><td>{{ a.recargos }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-if="tab==='pagos'">
        <h3>Pagos</h3>
        <table class="table table-sm">
          <thead><tr><th>Año</th><th>Mes</th><th>Fecha Pago</th><th>Importe</th><th>Usuario</th></tr></thead>
          <tbody>
            <tr v-for="p in pagos" :key="p.axo+'-'+p.periodo">
              <td>{{ p.axo }}</td><td>{{ p.periodo }}</td><td>{{ p.fecha_pago }}</td><td>{{ p.importe_pago }}</td><td>{{ p.usuario }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-if="tab==='requerimientos'">
        <h3>Requerimientos</h3>
        <table class="table table-sm">
          <thead><tr><th>Folio</th><th>Fecha Emisión</th><th>Importe Multa</th><th>Importe Gastos</th><th>Vigencia</th></tr></thead>
          <tbody>
            <tr v-for="r in requerimientos" :key="r.folio">
              <td>{{ r.folio }}</td><td>{{ r.fecha_emision }}</td><td>{{ r.importe_multa }}</td><td>{{ r.importe_gastos }}</td><td>{{ r.vigencia }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'ConsultaGeneralPage',
  data() {
    return {
      form: {
        oficina: '',
        num_mercado: '',
        categoria: '',
        seccion: '',
        local: '',
        letra_local: '',
        bloque: ''
      },
      recaudadoras: [],
      secciones: [],
      locales: [],
      detalle: null,
      adeudos: [],
      pagos: [],
      requerimientos: [],
      tab: 'adeudos',
      error: ''
    }
  },
  created() {
    // this.fetchCatalogs();
  },
  methods: {

    async buscarLocal() {
      this.error = '';
      this.locales = [];
      this.detalle = null;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'mercados.buscar_local',
          payload: this.form
        });
        if (res.data.status === 'success') {
          this.locales = res.data.data;
        } else {
          this.error = res.data.message;
        }
      } catch (error) {
        this.error = error.message;
      }
    },
    async verDetalle(id_local) {
      this.error = '';
      this.detalle = null;
      this.adeudos = [];
      this.pagos = [];
      this.requerimientos = [];
      try {
        // Detalle
        let res = await this.$axios.post('/api/execute', {
          action: 'mercados.detalle_local',
          payload: {id_local}
        });
        if (res.data.status === 'success' && res.data.data.length) {
          this.detalle = res.data.data[0];
        } else {
          this.error = res.data.message;
          return;
        }
        // Adeudos
        res = await this.$axios.post('/api/execute', {
          action: 'mercados.adeudos_local',
          payload: {id_local}
        });
        if (res.data.status === 'success') {
          this.adeudos = res.data.data;
        }
        // Pagos
        res = await this.$axios.post('/api/execute', {
          action: 'mercados.pagos_local',
          payload: {id_local}
        });
        if (res.data.status === 'success') {
          this.pagos = res.data.data;
        }
        // Requerimientos
        res = await this.$axios.post('/api/execute', {
          action: 'mercados.requerimientos_local',
          payload: {id_local}
        });
        if (res.data.status === 'success') {
          this.requerimientos = res.data.data;
        }
      } catch (error) {
        this.error = error.message;
      }
    }
  }
}
</script>

<style scoped>
.consulta-general-page { max-width: 1200px; margin: 0 auto; }
.breadcrumb { margin-bottom: 1em; }
.form-row { display: flex; flex-wrap: wrap; gap: 1em; align-items: center; }
.form-row label { min-width: 80px; }
.table { width: 100%; margin-top: 1em; }
.tabs { margin-top: 1em; }
.tabs button { margin-right: 1em; }
.tabs button.active { font-weight: bold; }
.alert { color: #b00; margin-top: 1em; }
</style>
