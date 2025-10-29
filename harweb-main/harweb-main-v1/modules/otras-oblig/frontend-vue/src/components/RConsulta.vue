<template>
  <div class="rconsulta-page">
    <h1>Consulta de Local/Concesión</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Consulta de Local
    </div>
    <div class="form-section">
      <form @submit.prevent="buscarConcesion">
        <div class="form-row">
          <label for="numero">Número de Local</label>
          <input v-model="numero" id="numero" maxlength="3" required @keypress="soloNumeros($event)" />
          <label for="letra">Letra</label>
          <input v-model="letra" id="letra" maxlength="1" style="text-transform:uppercase" />
          <button type="submit">Buscar</button>
          <button type="button" @click="limpiar">Limpiar</button>
        </div>
      </form>
    </div>
    <div v-if="concesion" class="concesion-info">
      <h2>Datos del Local</h2>
      <table class="info-table">
        <tr><th>Concesionario</th><td>{{ concesion.concesionario }}</td></tr>
        <tr><th>Ubicación</th><td>{{ concesion.ubicacion }}</td></tr>
        <tr><th>Estado</th><td>{{ concesion.descrip_stat }}</td></tr>
        <tr><th>Recaudadora</th><td>{{ concesion.id_recaudadora }}</td></tr>
        <tr><th>Sector</th><td>{{ concesion.sector }}</td></tr>
        <tr><th>Zona</th><td>{{ concesion.id_zona }}</td></tr>
        <tr><th>Inicio Obligación</th><td>{{ concesion.fecha_inicio }}</td></tr>
        <tr><th>Superficie (m²)</th><td>{{ concesion.superficie }}</td></tr>
        <tr><th>No. Licencia</th><td>{{ concesion.licencia }}</td></tr>
        <tr><th>Tipo de Local</th><td>{{ concesion.descrip_unidad }}</td></tr>
      </table>
    </div>
    <div v-if="adeudos.length" class="adeudos-section">
      <h2>Adeudos</h2>
      <table class="adeudos-table">
        <thead>
          <tr>
            <th>Concepto</th>
            <th>Renta</th>
            <th>Rcgo. Renta</th>
            <th>Dcto. Renta</th>
            <th>Dcto. Rcgos.</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in adeudos" :key="row.axo + '-' + row.mes + '-' + row.concepto">
            <td>{{ row.concepto }}</td>
            <td>{{ row.importe_pagar | money }}</td>
            <td>{{ row.recargos_pagar | money }}</td>
            <td>{{ row.dscto_importe | money }}</td>
            <td>{{ row.dscto_recargos | money }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="totales.length" class="totales-section">
      <h2>Totales</h2>
      <table class="totales-table">
        <thead>
          <tr>
            <th>Cuenta</th>
            <th>Concepto</th>
            <th>Importe</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in totales" :key="row.cuenta + '-' + row.concepto">
            <td>{{ row.cuenta }}</td>
            <td>{{ row.concepto }}</td>
            <td>{{ row.importe | money }}</td>
          </tr>
        </tbody>
      </table>
      <div class="total-pagar">
        <strong>Total a Pagar: </strong> {{ totalPagar | money }}
      </div>
    </div>
    <div v-if="pagados.length" class="pagados-section">
      <h2>Pagos Realizados</h2>
      <table class="pagados-table">
        <thead>
          <tr>
            <th>Periodo</th>
            <th>Importe</th>
            <th>Recargo</th>
            <th>Fecha Pago</th>
            <th>Folio Recibo</th>
            <th>Usuario</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in pagados" :key="row.id_34_pagos">
            <td>{{ row.periodo | date }}</td>
            <td>{{ row.importe | money }}</td>
            <td>{{ row.recargo | money }}</td>
            <td>{{ row.fecha_hora_pago | datetime }}</td>
            <td>{{ row.folio_recibo }}</td>
            <td>{{ row.usuario }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="error" class="error-message">
      <strong>Error:</strong> {{ error }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'RConsultaPage',
  data() {
    return {
      numero: '',
      letra: '',
      concesion: null,
      adeudos: [],
      totales: [],
      pagados: [],
      totalPagar: 0,
      error: null
    };
  },
  methods: {
    async buscarConcesion() {
      this.error = null;
      this.concesion = null;
      this.adeudos = [];
      this.totales = [];
      this.pagados = [];
      this.totalPagar = 0;
      if (!this.numero || this.numero === '0') {
        this.error = 'Falta el dato del NUMERO DE LOCAL, intentalo de nuevo';
        return;
      }
      const control = this.numero + (this.letra ? '-' + this.letra.toUpperCase() : '');
      try {
        // 1. Buscar concesión
        let res = await this.$axios.post('/api/execute', {
          action: 'get_concesion_by_control',
          params: { control }
        });
        if (!res.data.success || !res.data.data.length) {
          this.error = 'No existe LOCAL con este dato, intentalo de nuevo';
          return;
        }
        this.concesion = res.data.data[0];
        if (this.concesion.cve_stat !== 'V') {
          this.error = 'LOCAL EN SUSPENSION O CANCELADO, intentalo de nuevo';
          return;
        }
        // 2. Buscar fecha límite
        let fechaLimiteRes = await this.$axios.post('/api/execute', {
          action: 'get_fecha_limite',
          params: {}
        });
        let fechaLimite = fechaLimiteRes.data.data[0]?.fechalimite;
        let fechaActual = new Date();
        let periodo = '';
        if (fechaLimite) {
          let lim = new Date(fechaLimite);
          let year = fechaActual.getFullYear();
          let month = fechaActual.getMonth() + 1;
          if (fechaActual.getDate() > lim.getDate()) {
            periodo = year + '-' + month;
          } else {
            if (month === 1) {
              periodo = (year - 1) + '-12';
            } else {
              periodo = year + '-' + (month - 1);
            }
          }
        } else {
          periodo = fechaActual.getFullYear() + '-' + (fechaActual.getMonth() + 1);
        }
        // 3. Buscar adeudos
        let adeudosRes = await this.$axios.post('/api/execute', {
          action: 'get_adeudos_by_concesion',
          params: {
            id_34_datos: this.concesion.id_34_datos,
            aso: parseInt(periodo.split('-')[0]),
            mes: parseInt(periodo.split('-')[1])
          }
        });
        this.adeudos = adeudosRes.data.data || [];
        // 4. Buscar totales
        let totalesRes = await this.$axios.post('/api/execute', {
          action: 'get_totales_by_concesion',
          params: {
            id_34_datos: this.concesion.id_34_datos,
            aso: parseInt(periodo.split('-')[0]),
            mes: parseInt(periodo.split('-')[1])
          }
        });
        this.totales = totalesRes.data.data || [];
        this.totalPagar = this.totales.reduce((sum, row) => sum + parseFloat(row.importe), 0);
        // 5. Buscar pagos realizados
        let pagadosRes = await this.$axios.post('/api/execute', {
          action: 'get_pagados_by_concesion',
          params: { id_34_datos: this.concesion.id_34_datos }
        });
        this.pagados = pagadosRes.data.data || [];
      } catch (e) {
        this.error = e.response?.data?.error || e.message;
      }
    },
    limpiar() {
      this.numero = '';
      this.letra = '';
      this.concesion = null;
      this.adeudos = [];
      this.totales = [];
      this.pagados = [];
      this.totalPagar = 0;
      this.error = null;
    },
    soloNumeros(evt) {
      const charCode = evt.which ? evt.which : evt.keyCode;
      if (charCode < 48 || charCode > 57) {
        evt.preventDefault();
      }
    }
  },
  filters: {
    money(val) {
      if (val == null) return '';
      return '$' + parseFloat(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    },
    date(val) {
      if (!val) return '';
      return new Date(val).toLocaleDateString('es-MX');
    },
    datetime(val) {
      if (!val) return '';
      let d = new Date(val);
      return d.toLocaleDateString('es-MX') + ' ' + d.toLocaleTimeString('es-MX');
    }
  }
};
</script>

<style scoped>
.rconsulta-page {
  max-width: 1000px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
  font-size: 0.95em;
  color: #888;
}
.form-section {
  background: #f9f9f9;
  padding: 1rem;
  border-radius: 6px;
  margin-bottom: 1.5rem;
}
.form-row {
  display: flex;
  align-items: center;
  gap: 1rem;
}
.info-table, .adeudos-table, .totales-table, .pagados-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1rem;
}
.info-table th, .info-table td,
.adeudos-table th, .adeudos-table td,
.totales-table th, .totales-table td,
.pagados-table th, .pagados-table td {
  border: 1px solid #ddd;
  padding: 0.5rem;
}
.info-table th {
  background: #f0f0f0;
  text-align: right;
}
.adeudos-table th, .totales-table th, .pagados-table th {
  background: #e0e0e0;
}
.total-pagar {
  font-size: 1.2em;
  font-weight: bold;
  margin-top: 1rem;
}
.error-message {
  color: #b00;
  background: #ffe0e0;
  padding: 1rem;
  border-radius: 6px;
  margin-top: 1rem;
}
</style>
