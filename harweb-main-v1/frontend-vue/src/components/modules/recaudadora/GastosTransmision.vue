<template>
  <div class="gastos-transmision-page">
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Gastos de Transmisión Patrimonial
    </div>
    <h1>Captura de Gastos de Transmisión Patrimonial</h1>
    <form @submit.prevent="consultarFolio">
      <div class="form-group">
        <label for="folio">Folio Transmisión:</label>
        <input v-model.number="folio" id="folio" type="number" required class="form-control" :disabled="loading" />
      </div>
      <div class="form-group">
        <label>Módulo:</label>
        <select v-model="opc" class="form-control" :disabled="loading">
          <option value="T">Transmisión Patrimonial</option>
          <option value="D">Diferencia de Transmisión Patrimonial</option>
        </select>
      </div>
      <button type="submit" class="btn btn-primary" :disabled="loading">Consultar</button>
      <button type="button" class="btn btn-secondary ml-2" @click="limpiar" :disabled="loading">Limpiar</button>
    </form>
    <div v-if="consulta" class="consulta-result mt-4">
      <h2>Detalle del Folio</h2>
      <table class="table table-bordered">
        <tr><th>Folio Glosa</th><td>{{ consulta.folioglosa }}</td></tr>
        <tr><th>Impuesto</th><td>{{ consulta.impuesto | currency }}</td></tr>
        <tr><th>Recargos</th><td>{{ consulta.recargos | currency }}</td></tr>
        <tr><th>Multa Extemporánea</th><td>{{ consulta.multaext | currency }}</td></tr>
        <tr><th>Multa Impuesto</th><td>{{ consulta.multaimp | currency }}</td></tr>
        <tr><th>Gastos</th><td>{{ consulta.gastos | currency }}</td></tr>
        <tr><th>Actualización</th><td>{{ consulta.actualizacion | currency }}</td></tr>
        <tr><th>Total</th><td>{{ consulta.total | currency }}</td></tr>
        <tr><th>Mensaje</th><td>{{ consulta.mensaje }}</td></tr>
      </table>
      <div class="form-group mt-3">
        <label for="gastos">Gastos a Aplicar:</label>
        <input v-model.number="gastos" id="gastos" type="number" min="0" step="0.01" class="form-control" :disabled="aplicando || consulta.estatus !== 0" />
      </div>
      <div class="form-group">
        <button class="btn btn-success" @click="aplicarGastos" :disabled="aplicando || consulta.estatus !== 0">Aplicar Gastos</button>
        <button class="btn btn-warning ml-2" @click="limpiar" :disabled="aplicando">Otro Folio</button>
      </div>
      <div v-if="aplicaMsg" class="alert" :class="{'alert-success': aplicaEstado, 'alert-danger': !aplicaEstado}">
        {{ aplicaMsg }}
      </div>
    </div>
    <div v-if="loading" class="loading">Procesando...</div>
  </div>
</template>

<script>
export default {
  name: 'GastosTransmisionPage',
  data() {
    return {
      folio: '',
      opc: 'T',
      consulta: null,
      gastos: '',
      loading: false,
      aplicando: false,
      aplicaMsg: '',
      aplicaEstado: null
    };
  },
  methods: {
    async consultarFolio() {
      this.loading = true;
      this.consulta = null;
      this.aplicaMsg = '';
      this.gastos = '';
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'consulta_foliotransm',
            params: { folio: this.folio, opc: this.opc }
          })
        });
        const data = await response.json();
        if (data.success) {
          this.consulta = data.data;
          this.gastos = data.data.gastos;
        } else {
          this.consulta = null;
          this.aplicaMsg = data.message;
          this.aplicaEstado = false;
        }
      } catch (e) {
        this.aplicaMsg = 'Error de red o servidor';
        this.aplicaEstado = false;
      } finally {
        this.loading = false;
      }
    },
    async aplicarGastos() {
      if (!this.gastos || isNaN(this.gastos) || this.gastos < 0) {
        this.aplicaMsg = 'Ingrese un monto de gastos válido';
        this.aplicaEstado = false;
        return;
      }
      this.aplicando = true;
      this.aplicaMsg = '';
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'afecta_gastostransm',
            params: { folio: this.folio, gastos: this.gastos, opc: this.opc }
          })
        });
        const data = await response.json();
        this.aplicaMsg = data.message;
        this.aplicaEstado = data.success;
        if (data.success) {
          this.consulta = null;
          this.gastos = '';
        }
      } catch (e) {
        this.aplicaMsg = 'Error de red o servidor';
        this.aplicaEstado = false;
      } finally {
        this.aplicando = false;
      }
    },
    limpiar() {
      this.folio = '';
      this.consulta = null;
      this.gastos = '';
      this.aplicaMsg = '';
      this.aplicaEstado = null;
    }
  },
  filters: {
    currency(val) {
      if (val === null || val === undefined) return '';
      return '$' + parseFloat(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
};
</script>

<style scoped>
.gastos-transmision-page {
  max-width: 700px;
  margin: 0 auto;
  padding: 2rem;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px #0001;
}
.breadcrumb {
  margin-bottom: 1rem;
  font-size: 0.95rem;
}
.form-group {
  margin-bottom: 1rem;
}
.loading {
  color: #888;
  margin-top: 2rem;
}
.alert {
  margin-top: 1rem;
  padding: 1rem;
  border-radius: 4px;
}
.alert-success {
  background: #e6ffe6;
  color: #1a7f1a;
}
.alert-danger {
  background: #ffe6e6;
  color: #a00;
}
</style>
