<template>
  <div class="drecgo-lic-page">
    <nav class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Descuentos en Recargos y Multas Licencias</span>
    </nav>
    <h1>Descuentos en Recargos y Multas Licencias</h1>
    <form @submit.prevent="onBuscar">
      <div class="form-row">
        <label for="folio">Licencia/Anuncio:</label>
        <input v-model="folio" id="folio" type="text" required />
        <select v-model="tipo">
          <option value="L">Licencia</option>
          <option value="A">Anuncio</option>
        </select>
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="busqueda.length">
      <h2>Resultado</h2>
      <table class="result-table">
        <thead>
          <tr>
            <th>Id</th>
            <th>Licencia/Anuncio</th>
            <th>Propietario</th>
            <th>Min</th>
            <th>Max</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in busqueda" :key="item.id_licencia || item.id_anuncio">
            <td>{{ item.id_licencia || item.id_anuncio }}</td>
            <td>{{ item.licencia || item.anuncio }}</td>
            <td>{{ item.propietario }}</td>
            <td>{{ item.min }}</td>
            <td>{{ item.max }}</td>
          </tr>
        </tbody>
      </table>
      <div class="actions">
        <button @click="abrirDescuento('recargo')">Descuento Recargo</button>
        <button @click="abrirDescuento('multa')">Descuento Multa</button>
      </div>
    </div>
    <div v-if="showDescuento">
      <h2>Alta de Descuento ({{ descuentoTipo==='recargo' ? 'Recargo' : 'Multa' }})</h2>
      <form @submit.prevent="onAltaDescuento">
        <div class="form-row">
          <label>Porcentaje:</label>
          <input v-model.number="porcentaje" type="number" min="1" max="100" required />
        </div>
        <div class="form-row">
          <label>Autoriza:</label>
          <select v-model="autoriza" required>
            <option v-for="f in funcionarios" :key="f.cveautoriza" :value="f.cveautoriza">
              {{ f.descripcion }} ({{ f.porcentajetope }}%)
            </option>
          </select>
        </div>
        <div class="form-row">
          <label>Periodo Desde:</label>
          <input v-model.number="axoini" type="number" min="2000" required />
          <label>Hasta:</label>
          <input v-model.number="axofin" type="number" min="2000" required />
        </div>
        <button type="submit">Registrar Descuento</button>
        <button type="button" @click="showDescuento=false">Cancelar</button>
      </form>
    </div>
    <div v-if="mensaje" class="mensaje">
      {{ mensaje }}
    </div>
    <div v-if="errores.length" class="errores">
      <ul>
        <li v-for="e in errores" :key="e">{{ e }}</li>
      </ul>
    </div>
  </div>
</template>

<script>
export default {
  name: 'DrecgoLicPage',
  data() {
    return {
      folio: '',
      tipo: 'L',
      busqueda: [],
      showDescuento: false,
      descuentoTipo: '',
      porcentaje: 0,
      autoriza: '',
      axoini: '',
      axofin: '',
      funcionarios: [],
      mensaje: '',
      errores: []
    }
  },
  methods: {
    async onBuscar() {
      this.mensaje = '';
      this.errores = [];
      this.busqueda = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: this.tipo === 'L' ? 'searchLicencia' : 'searchAnuncio',
            params: { folio: this.folio, tipo: this.tipo }
          }
        });
        if (res.data.eResponse.success) {
          this.busqueda = res.data.eResponse.data;
        } else {
          this.errores.push(res.data.eResponse.message);
        }
      } catch (e) {
        this.errores.push(e.message);
      }
    },
    async abrirDescuento(tipo) {
      this.descuentoTipo = tipo;
      this.showDescuento = true;
      this.porcentaje = 0;
      this.axoini = this.busqueda[0]?.min || '';
      this.axofin = this.busqueda[0]?.max || '';
      // Consulta funcionarios autorizados
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'consultaFuncionarios',
            params: { tipo: tipo === 'recargo' ? 'recargo' : 'multa' }
          }
        });
        if (res.data.eResponse.success) {
          this.funcionarios = res.data.eResponse.data;
        } else {
          this.errores.push(res.data.eResponse.message);
        }
      } catch (e) {
        this.errores.push(e.message);
      }
    },
    async onAltaDescuento() {
      this.mensaje = '';
      this.errores = [];
      if (!this.porcentaje || !this.autoriza || !this.axoini || !this.axofin) {
        this.errores.push('Todos los campos son obligatorios');
        return;
      }
      // Validación de porcentaje máximo
      const func = this.funcionarios.find(f => f.cveautoriza == this.autoriza);
      if (func && this.porcentaje > func.porcentajetope) {
        this.errores.push('Porcentaje de descuento mayor al permitido por quien autoriza');
        return;
      }
      try {
        const params = {
          tipo: this.tipo,
          licencia: this.busqueda[0]?.id_licencia || this.busqueda[0]?.id_anuncio,
          porcentaje: this.porcentaje,
          usuario: this.$store.state.usuario,
          axoini: this.axoini,
          axofin: this.axofin,
          autoriza: this.autoriza,
          minmax: `${this.axoini},${this.axofin}`
        };
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: this.descuentoTipo === 'recargo' ? 'altaRecargo' : 'altaMulta',
            params
          }
        });
        if (res.data.eResponse.success) {
          this.mensaje = res.data.eResponse.message;
          this.showDescuento = false;
          this.onBuscar();
        } else {
          this.errores.push(res.data.eResponse.message);
        }
      } catch (e) {
        this.errores.push(e.message);
      }
    }
  }
}
</script>

<style scoped>
.drecgo-lic-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
.result-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1rem;
}
.result-table th, .result-table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.actions {
  margin-bottom: 1rem;
}
.mensaje {
  color: green;
  font-weight: bold;
}
.errores {
  color: red;
}
</style>
