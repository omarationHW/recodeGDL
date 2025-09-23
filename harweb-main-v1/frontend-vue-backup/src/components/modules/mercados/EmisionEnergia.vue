<template>
  <div class="emision-energia-page">
    <nav class="breadcrumb">
      <span>Inicio</span> &gt; <span>Emisión de Recibos de Energía Eléctrica</span>
    </nav>
    <h1>Emisión de Recibos de Energía Eléctrica</h1>
    <form @submit.prevent="onEjecutar">
      <div class="form-row">
        <label>Recaudadora</label>
        <select v-model="form.oficina" @change="onRecaudadoraChange">
          <option value="">Seleccione...</option>
          <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }} - {{ rec.recaudadora }}</option>
        </select>
      </div>
      <div class="form-row">
        <label>Mercado</label>
        <select v-model="form.mercado">
          <option value="">Seleccione...</option>
          <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">{{ merc.num_mercado_nvo }} - {{ merc.descripcion }}</option>
        </select>
      </div>
      <div class="form-row">
        <label>Año</label>
        <input type="number" v-model.number="form.axo" min="2003" max="2999" />
      </div>
      <div class="form-row">
        <label>Periodo (Mes)</label>
        <input type="number" v-model.number="form.periodo" min="1" max="12" />
      </div>
      <div class="form-actions">
        <button type="button" @click="onEjecutar">Emisión</button>
        <button type="button" @click="onGrabar">Grabar</button>
        <button type="button" @click="onFacturacion">Facturación</button>
        <button type="button" @click="onSalir">Salir</button>
      </div>
    </form>
    <div v-if="emision.length">
      <h2>Detalle de Emisión</h2>
      <table class="table table-sm table-bordered">
        <thead>
          <tr>
            <th>Local</th>
            <th>Nombre</th>
            <th>Descripción</th>
            <th>Importe</th>
            <th>Consumo</th>
            <th>Cantidad</th>
            <th>Importe Energía</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in emision" :key="row.id_energia">
            <td>{{ row.local }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.descripcion }}</td>
            <td>{{ row.importe }}</td>
            <td>{{ row.cve_consumo }}</td>
            <td>{{ row.cantidad }}</td>
            <td>{{ row.importe_energia }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="message" class="alert" :class="{'alert-danger': error, 'alert-success': !error}">{{ message }}</div>
  </div>
</template>

<script>
export default {
  name: 'EmisionEnergiaPage',
  data() {
    return {
      recaudadoras: [],
      mercados: [],
      emision: [],
      form: {
        oficina: '',
        mercado: '',
        axo: new Date().getFullYear(),
        periodo: new Date().getMonth() + 1
      },
      message: '',
      error: false
    };
  },
  created() {
    this.loadRecaudadoras();
  },
  methods: {
    async api(action, params = {}) {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action, params } })
      });
      const json = await res.json();
      return json.eResponse;
    },
    async loadRecaudadoras() {
      const resp = await this.api('getRecaudadoras');
      if (resp.status === 'ok') {
        this.recaudadoras = resp.data;
      }
    },
    async onRecaudadoraChange() {
      this.form.mercado = '';
      this.mercados = [];
      if (this.form.oficina) {
        const resp = await this.api('getMercadosByRecaudadora', { oficina: this.form.oficina });
        if (resp.status === 'ok') {
          this.mercados = resp.data;
        }
      }
    },
    async onEjecutar() {
      this.message = '';
      this.error = false;
      if (!this.form.oficina || !this.form.mercado) {
        this.message = 'Debe seleccionar recaudadora y mercado.';
        this.error = true;
        return;
      }
      const resp = await this.api('getEmisionEnergia', {
        oficina: this.form.oficina,
        mercado: this.form.mercado,
        axo: this.form.axo,
        periodo: this.form.periodo
      });
      if (resp.status === 'ok') {
        this.emision = resp.data;
        if (!this.emision.length) {
          this.message = 'No hay datos para la emisión.';
        }
      } else {
        this.message = resp.message;
        this.error = true;
      }
    },
    async onGrabar() {
      this.message = '';
      this.error = false;
      if (!this.form.oficina || !this.form.mercado) {
        this.message = 'Debe seleccionar recaudadora y mercado.';
        this.error = true;
        return;
      }
      const usuario = 1; // TODO: obtener usuario logueado
      const resp = await this.api('grabarEmisionEnergia', {
        oficina: this.form.oficina,
        mercado: this.form.mercado,
        axo: this.form.axo,
        periodo: this.form.periodo,
        usuario
      });
      this.message = resp.message;
      this.error = resp.status !== 'ok';
    },
    async onFacturacion() {
      this.message = '';
      this.error = false;
      if (!this.form.oficina || !this.form.mercado) {
        this.message = 'Debe seleccionar recaudadora y mercado.';
        this.error = true;
        return;
      }
      const resp = await this.api('facturarEmisionEnergia', {
        oficina: this.form.oficina,
        mercado: this.form.mercado,
        axo: this.form.axo,
        periodo: this.form.periodo
      });
      if (resp.status === 'ok') {
        // Aquí podría abrir un PDF, mostrar datos, etc.
        this.message = 'Facturación generada correctamente.';
      } else {
        this.message = resp.message;
        this.error = true;
      }
    },
    onSalir() {
      this.$router.push('/');
    }
  }
};
</script>

<style scoped>
.emision-energia-page {
  max-width: 700px;
  margin: 0 auto;
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
}
.form-row {
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
}
.form-row label {
  width: 120px;
  font-weight: bold;
}
.form-row input, .form-row select {
  flex: 1;
  padding: 0.3rem;
}
.form-actions {
  margin-top: 1.5rem;
  display: flex;
  gap: 1rem;
}
.alert {
  margin-top: 1rem;
  padding: 0.7rem;
  border-radius: 4px;
}
.alert-danger {
  background: #ffe0e0;
  color: #a00;
}
.alert-success {
  background: #e0ffe0;
  color: #080;
}
.breadcrumb {
  font-size: 0.9rem;
  color: #888;
  margin-bottom: 1rem;
}
</style>
