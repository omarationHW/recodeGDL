<template>
  <div class="adeudos-pagmult-page">
    <h1>Dar de Pagado Excedencias Vigentes en forma Múltiple</h1>
    <div class="breadcrumb">Inicio &gt; Adeudos &gt; Pagos Múltiples</div>
    <form @submit.prevent="buscarContrato">
      <fieldset>
        <legend>Contrato y Tipo de Aseo</legend>
        <label>
          Contrato:
          <input v-model="form.contrato" type="number" required />
        </label>
        <label>
          Tipo de Aseo:
          <select v-model="form.ctrol_aseo" required>
            <option v-for="t in catalogos.tipos_aseo" :key="t.ctrol_aseo" :value="t.ctrol_aseo">
              {{ t.ctrol_aseo }} - {{ t.tipo_aseo }} - {{ t.descripcion }}
            </option>
          </select>
        </label>
        <button type="submit">Buscar</button>
      </fieldset>
    </form>
    <div v-if="contrato">
      <h2>Contrato: {{ contrato.num_contrato }} (Control: {{ contrato.control_contrato }})</h2>
      <button @click="listarAdeudos">Ver Adeudos Vigentes</button>
    </div>
    <div v-if="adeudos.length">
      <h3>Adeudos Vigentes</h3>
      <table class="adeudos-table">
        <thead>
          <tr>
            <th></th>
            <th>Periodo</th>
            <th>Operación</th>
            <th>No. Exed</th>
            <th>Importe</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(ad, idx) in adeudos" :key="idx">
            <td><input type="checkbox" v-model="ad.selected" /></td>
            <td>{{ ad.aso_mes_pago.substr(0,7) }}</td>
            <td>{{ ad.descripcion }}</td>
            <td>{{ ad.exedencias }}</td>
            <td>{{ ad.importe | currency }}</td>
          </tr>
        </tbody>
      </table>
      <form @submit.prevent="pagarSeleccionados">
        <fieldset>
          <legend>Datos de Pago</legend>
          <label>
            Fecha de Pago:
            <input type="datetime-local" v-model="pago.fecha_pagado" required />
          </label>
          <label>
            Recaudadora:
            <select v-model="pago.id_rec" required>
              <option v-for="r in catalogos.recaudadoras" :key="r.id_rec" :value="r.id_rec">
                {{ r.id_rec }} - {{ r.recaudadora }}
              </option>
            </select>
          </label>
          <label>
            Caja:
            <select v-model="pago.caja" required>
              <option v-for="c in catalogos.cajas" :key="c.caja" :value="c.caja">{{ c.caja }}</option>
            </select>
          </label>
          <label>
            Consecutivo de Operación:
            <input type="number" v-model="pago.consec_operacion" required />
          </label>
          <label>
            Folio Recibo:
            <input type="text" v-model="pago.folio_rcbo" />
          </label>
          <button type="submit">Dar de Pagado Seleccionados</button>
        </fieldset>
      </form>
    </div>
    <div v-if="msg" class="msg">{{ msg }}</div>
  </div>
</template>

<script>
export default {
  name: 'AdeudosPagMultPage',
  data() {
    return {
      catalogos: {
        tipos_aseo: [],
        recaudadoras: [],
        cajas: []
      },
      form: {
        contrato: '',
        ctrol_aseo: ''
      },
      contrato: null,
      adeudos: [],
      pago: {
        fecha_pagado: '',
        id_rec: '',
        caja: '',
        consec_operacion: '',
        folio_rcbo: ''
      },
      msg: ''
    };
  },
  filters: {
    currency(val) {
      return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(val);
    }
  },
  created() {
    this.cargarCatalogos();
  },
  methods: {
    async cargarCatalogos() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'listar_catalogos' } })
      });
      const data = await res.json();
      this.catalogos = data.eResponse;
    },
    async buscarContrato() {
      this.msg = '';
      this.contrato = null;
      this.adeudos = [];
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest: { action: 'buscar_contrato', contrato: this.form.contrato, ctrol_aseo: this.form.ctrol_aseo } })
        });
        const data = await res.json();
        this.contrato = data.eResponse.contrato;
      } catch (e) {
        this.msg = 'Contrato no encontrado';
      }
    },
    async listarAdeudos() {
      this.msg = '';
      this.adeudos = [];
      if (!this.contrato) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'listar_adeudos', control_contrato: this.contrato.control_contrato } })
      });
      const data = await res.json();
      this.adeudos = (data.eResponse.adeudos || []).map(a => ({ ...a, selected: false }));
    },
    async pagarSeleccionados() {
      this.msg = '';
      const seleccionados = this.adeudos.filter(a => a.selected);
      if (!seleccionados.length) {
        this.msg = 'Seleccione al menos un adeudo.';
        return;
      }
      // Validar datos de pago
      if (!this.pago.fecha_pagado || !this.pago.id_rec || !this.pago.caja || !this.pago.consec_operacion) {
        this.msg = 'Complete todos los datos de pago.';
        return;
      }
      // Simular usuario autenticado
      const usuario = 1; // Reemplazar por auth real
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'pagar_adeudos',
            params: {
              adeudos: seleccionados.map(a => ({
                control_contrato: a.control_contrato,
                aso_mes_pago: a.aso_mes_pago,
                ctrol_operacion: a.ctrol_operacion
              })),
              fecha_pagado: this.pago.fecha_pagado,
              id_rec: this.pago.id_rec,
              caja: this.pago.caja,
              consec_operacion: this.pago.consec_operacion,
              folio_rcbo: this.pago.folio_rcbo,
              usuario
            }
          }
        })
      });
      const data = await res.json();
      if (data.eResponse.success) {
        this.msg = 'Adeudos pagados correctamente.';
        this.listarAdeudos();
      } else {
        this.msg = data.eResponse.error || 'Error al pagar.';
      }
    }
  }
};
</script>

<style scoped>
.adeudos-pagmult-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2em;
}
.adeudos-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1em;
}
.adeudos-table th, .adeudos-table td {
  border: 1px solid #ccc;
  padding: 0.5em;
  text-align: center;
}
.msg {
  margin-top: 1em;
  color: #b00;
}
.breadcrumb {
  font-size: 0.9em;
  color: #888;
  margin-bottom: 1em;
}
</style>
