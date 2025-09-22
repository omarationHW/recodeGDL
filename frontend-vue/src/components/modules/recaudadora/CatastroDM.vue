<template>
  <div class="catastrodm-formulario">
    <h1>CatastroDM - Descuentos Predial</h1>
    <form @submit.prevent="buscarCuenta">
      <label>Clave Catastral:</label>
      <input v-model="clave" required />
      <button type="submit">Buscar</button>
    </form>
    <div v-if="cuenta">
      <h2>Cuenta: {{ cuenta.cvecuenta }}</h2>
      <p><strong>Clave:</strong> {{ cuenta.cvecatnva }}</p>
      <p><strong>Recaudadora:</strong> {{ cuenta.recaud }}</p>
      <p><strong>Urb/Rus:</strong> {{ cuenta.urbrus }}</p>
      <p><strong>Cuenta:</strong> {{ cuenta.cuenta }}</p>
      <h3>Adeudos</h3>
      <table border="1">
        <thead>
          <tr>
            <th>Año</th>
            <th>Bimestre</th>
            <th>Impuesto</th>
            <th>Recargos</th>
            <th>Saldo</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="a in adeudos" :key="a.axosal + '-' + a.bimsal">
            <td>{{ a.axosal }}</td>
            <td>{{ a.bimsal }}</td>
            <td>{{ a.impfac }}</td>
            <td>{{ a.recfac }}</td>
            <td>{{ a.saldo }}</td>
          </tr>
        </tbody>
      </table>
      <h3>Descuentos Vigentes</h3>
      <table border="1">
        <thead>
          <tr>
            <th>Tipo</th>
            <th>Bim. Ini</th>
            <th>Bim. Fin</th>
            <th>Solicitante</th>
            <th>Observaciones</th>
            <th>Fecha Alta</th>
            <th>Status</th>
            <th>Acción</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="d in descuentos" :key="d.id">
            <td>{{ d.cvedescuento }}</td>
            <td>{{ d.bimini }}</td>
            <td>{{ d.bimfin }}</td>
            <td>{{ d.solicitante }}</td>
            <td>{{ d.observaciones }}</td>
            <td>{{ d.fecalta }}</td>
            <td>{{ d.status }}</td>
            <td>
              <button v-if="d.status === 'V'" @click="cancelarDescuento(d.id)">Cancelar</button>
            </td>
          </tr>
        </tbody>
      </table>
      <h3>Agregar Descuento</h3>
      <form @submit.prevent="agregarDescuento">
        <label>Tipo de Descuento:</label>
        <select v-model="nuevoDescuento.cvedescuento" required>
          <option v-for="c in catalogoDescuentos" :value="c.cvedescuento">{{ c.descripcion }}</option>
        </select>
        <label>Bimestre Inicial:</label>
        <input v-model.number="nuevoDescuento.bimini" type="number" min="1" max="6" required />
        <label>Bimestre Final:</label>
        <input v-model.number="nuevoDescuento.bimfin" type="number" min="1" max="6" required />
        <label>Solicitante:</label>
        <input v-model="nuevoDescuento.solicitante" required />
        <label>Observaciones:</label>
        <input v-model="nuevoDescuento.observaciones" />
        <button type="submit">Agregar</button>
      </form>
    </div>
    <div v-if="error" class="error">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'CatastroDMFormulario',
  data() {
    return {
      clave: '',
      cuenta: null,
      adeudos: [],
      descuentos: [],
      catalogoDescuentos: [],
      nuevoDescuento: {
        cvedescuento: '',
        bimini: 1,
        bimfin: 6,
        solicitante: '',
        observaciones: ''
      },
      error: ''
    };
  },
  methods: {
    async buscarCuenta() {
      this.error = '';
      try {
        // Buscar cuenta
        let res = await this.$axios.post('/api/execute', {
          action: 'recaudadora.getCuentaByClave',
          payload: { clave: this.clave }
        });
        if (res.data.status !== 'success' || !res.data.data) {
          this.error = res.data.message || 'Cuenta no encontrada';
          return;
        }
        this.cuenta = res.data.data;
        // Buscar adeudos
        let res2 = await this.$axios.post('/api/execute', {
          action: 'recaudadora.getAdeudosByCuenta',
          payload: { cvecuenta: this.cuenta.cvecuenta }
        });
        this.adeudos = res2.data.data || [];
        // Buscar descuentos
        let res3 = await this.$axios.post('/api/execute', {
          action: 'recaudadora.getDescuentosPredial',
          payload: { cvecuenta: this.cuenta.cvecuenta }
        });
        this.descuentos = res3.data.data || [];
        // Catálogo descuentos
        let res4 = await this.$axios.post('/api/execute', {
          action: 'recaudadora.getCatalogoDescuentos',
          payload: {}
        });
        this.catalogoDescuentos = res4.data.data || [];
      } catch (e) {
        this.error = 'Error de conexión: ' + e.message;
      }
    },
    async agregarDescuento() {
      this.error = '';
      try {
        let params = {
          ...this.nuevoDescuento,
          cvecuenta: this.cuenta.cvecuenta,
          fecalta: new Date().toISOString().slice(0,10),
          captalta: 'usuario_demo',
          recaud: this.cuenta.recaud,
          foliodesc: Math.floor(Math.random()*100000),
          status: 'V'
        };
        let res = await this.$axios.post('/api/execute', {
          action: 'recaudadora.insertDescuentoPredial',
          payload: params
        });
        if (res.data.status !== 'success') {
          this.error = res.data.message;
          return;
        }
        this.buscarCuenta();
      } catch (e) {
        this.error = 'Error de conexión: ' + e.message;
      }
    },
    async cancelarDescuento(id) {
      this.error = '';
      try {
        let res = await this.$axios.post('/api/execute', {
          action: 'recaudadora.cancelarDescuentoPredial',
          payload: { id, usuario: 'usuario_demo' }
        });
        if (res.data.status !== 'success') {
          this.error = res.data.message;
          return;
        }
        this.buscarCuenta();
      } catch (e) {
        this.error = 'Error de conexión: ' + e.message;
      }
    }
  }
};
</script>

<style scoped>
.catastrodm-formulario {
  max-width: 900px;
  margin: 0 auto;
  padding: 2em;
  background: #f9f9f9;
}
.error {
  color: red;
  margin-top: 1em;
}
</style>
