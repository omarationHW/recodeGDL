<template>
  <div class="desc-derechos-merc-page">
    <h1>Descuento en renta (derechos) de mercados</h1>
    <form @submit.prevent="buscarLocal">
      <div class="form-row">
        <label>Recaudadora</label>
        <select v-model="form.recaud" @change="cargarMercados">
          <option v-for="rec in recaudadoras" :key="rec.recaud" :value="rec.recaud">{{ rec.descripcion }}</option>
        </select>
        <label>Mercado</label>
        <select v-model="form.num_merc" @change="cargarSecciones">
          <option v-for="merc in mercados" :key="merc.num_merc" :value="merc.num_merc">{{ merc.nombre }}</option>
        </select>
        <label>Sección</label>
        <select v-model="form.secc">
          <option v-for="secc in secciones" :key="secc.secc" :value="secc.secc">{{ secc.secc }}</option>
        </select>
        <label>Letra</label>
        <input v-model="form.letra" maxlength="1" style="width:40px" />
        <label>Bloque</label>
        <input v-model="form.bloque" maxlength="1" style="width:40px" />
        <label>Local</label>
        <input v-model="form.local" type="number" style="width:80px" />
        <button type="submit">Buscar Local</button>
      </div>
    </form>
    <div v-if="localEncontrado">
      <h2>Datos del Local</h2>
      <div>
        <strong>Nombre:</strong> {{ localEncontrado.nombre }}<br>
        <strong>Vigencia:</strong> {{ localEncontrado.vigencia }}<br>
        <strong>Bloqueo:</strong> {{ localEncontrado.bloqueo }}<br>
        <strong>Periodo mínimo:</strong> {{ localEncontrado.minimo }}<br>
        <strong>Periodo máximo:</strong> {{ localEncontrado.maximo }}<br>
      </div>
      <div v-if="descuentos.length">
        <h3>Descuentos Vigentes</h3>
        <table class="table">
          <thead>
            <tr>
              <th>Periodo Inicial</th>
              <th>Periodo Final</th>
              <th>Porcentaje</th>
              <th>Estado</th>
              <th>Usuario Alta</th>
              <th>Fecha Alta</th>
              <th>Acción</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="desc in descuentos" :key="desc.id_descuento">
              <td>{{ desc.axoini }}/{{ desc.mesini }}</td>
              <td>{{ desc.axofin }}/{{ desc.mesfin }}</td>
              <td>{{ desc.porcentaje }}%</td>
              <td>{{ desc.estado === 'V' ? 'VIGENTE' : desc.estado === 'P' ? 'PAGADO' : 'CANCELADO' }}</td>
              <td>{{ desc.usu_alta }}</td>
              <td>{{ formatDate(desc.fecha_alta) }}</td>
              <td>
                <button v-if="desc.estado === 'V'" @click="cancelarDescuento(desc)">Cancelar</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-else>
        <h3>No hay descuentos vigentes</h3>
      </div>
      <div v-if="puedeAgregarDescuento">
        <h3>Agregar Descuento</h3>
        <form @submit.prevent="agregarDescuento">
          <div class="form-row">
            <label>Periodo Final (AAAA-MM)</label>
            <input v-model="nuevoDescuento.periodo_final" placeholder="2024-12" maxlength="7" />
            <label>Porcentaje</label>
            <input v-model.number="nuevoDescuento.porcentaje" type="number" min="1" max="100" />
            <label>Autoriza</label>
            <select v-model="nuevoDescuento.autoriza">
              <option v-for="func in funcionarios" :key="func.cveautoriza" :value="func.cveautoriza">{{ func.descripcion }}</option>
            </select>
            <button type="submit">Agregar</button>
          </div>
        </form>
      </div>
    </div>
    <div v-if="mensaje" class="alert">{{ mensaje }}</div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'DescDerechosMercPage',
  data() {
    return {
      recaudadoras: [],
      mercados: [],
      secciones: [],
      funcionarios: [],
      form: {
        recaud: '',
        num_merc: '',
        secc: '',
        letra: '',
        bloque: '',
        local: ''
      },
      localEncontrado: null,
      descuentos: [],
      puedeAgregarDescuento: false,
      nuevoDescuento: {
        periodo_final: '',
        porcentaje: 0,
        autoriza: ''
      },
      mensaje: ''
    }
  },
  created() {
    this.cargarRecaudadoras();
    this.cargarFuncionarios();
  },
  methods: {
    async cargarRecaudadoras() {
      const res = await axios.post('/api/execute', { action: 'getRecaudadoras' });
      this.recaudadoras = res.data.data;
    },
    async cargarMercados() {
      if (!this.form.recaud) return;
      const res = await axios.post('/api/execute', { action: 'getMercados', params: { recaud: this.form.recaud } });
      this.mercados = res.data.data;
    },
    async cargarSecciones() {
      const res = await axios.post('/api/execute', { action: 'getSecciones' });
      this.secciones = res.data.data;
    },
    async cargarFuncionarios() {
      const res = await axios.post('/api/execute', { action: 'getFuncionarios', params: { permiso: false } });
      this.funcionarios = res.data.data;
    },
    async buscarLocal() {
      this.mensaje = '';
      this.localEncontrado = null;
      this.descuentos = [];
      this.puedeAgregarDescuento = false;
      // Validación básica
      if (!this.form.recaud || !this.form.num_merc || !this.form.secc || !this.form.local) {
        this.mensaje = 'Completa todos los campos para buscar el local.';
        return;
      }
      const params = {
        ofna: this.form.recaud,
        num_merc: this.form.num_merc,
        categ: this.mercados.find(m => m.num_merc == this.form.num_merc)?.categ || '',
        secc: this.form.secc,
        local: this.form.local,
        letra: this.form.letra,
        bloque: this.form.bloque
      };
      const res = await axios.post('/api/execute', { action: 'getLocal', params });
      if (res.data.data && res.data.data.length) {
        this.localEncontrado = res.data.data[0];
        // Buscar descuentos
        const res2 = await axios.post('/api/execute', { action: 'getDescuentosMercado', params: { id_local: this.localEncontrado.id_local } });
        this.descuentos = res2.data.data;
        this.puedeAgregarDescuento = !this.descuentos.some(d => d.estado === 'V');
      } else {
        this.mensaje = 'Local no encontrado, dado de baja o sin adeudo vencido.';
      }
    },
    async agregarDescuento() {
      this.mensaje = '';
      if (!this.nuevoDescuento.periodo_final.match(/^\d{4}-\d{2}$/)) {
        this.mensaje = 'El periodo final debe tener formato AAAA-MM.';
        return;
      }
      if (!this.nuevoDescuento.porcentaje || this.nuevoDescuento.porcentaje < 1 || this.nuevoDescuento.porcentaje > 100) {
        this.mensaje = 'Porcentaje inválido.';
        return;
      }
      if (!this.nuevoDescuento.autoriza) {
        this.mensaje = 'Selecciona quien autoriza.';
        return;
      }
      // Validar que no exista descuento vigente
      if (this.descuentos.some(d => d.estado === 'V')) {
        this.mensaje = 'Ya existe un descuento vigente para este local.';
        return;
      }
      // Lógica para periodo inicial/final
      const par_axoi = parseInt(this.localEncontrado.minimo.substring(0,4));
      const par_mesi = parseInt(this.localEncontrado.minimo.substring(5,7));
      const par_axof = parseInt(this.nuevoDescuento.periodo_final.substring(0,4));
      const par_mesf = parseInt(this.nuevoDescuento.periodo_final.substring(5,7));
      const res = await axios.post('/api/execute', {
        action: 'altaDescuentoMercado',
        params: {
          par_local: this.localEncontrado.id_local,
          par_axoi,
          par_mesi,
          par_axof,
          par_mesf,
          par_porc: this.nuevoDescuento.porcentaje,
          par_autoriza: this.nuevoDescuento.autoriza
        }
      });
      if (res.data.success) {
        this.mensaje = 'Descuento agregado correctamente.';
        await this.buscarLocal();
      } else {
        this.mensaje = res.data.message || 'Error al agregar descuento.';
      }
    },
    async cancelarDescuento(desc) {
      if (!confirm('¿Seguro que deseas cancelar este descuento?')) return;
      const par_axoi = desc.axoini;
      const par_mesi = desc.mesini;
      const par_axof = desc.axofin;
      const par_mesf = desc.mesfin;
      const res = await axios.post('/api/execute', {
        action: 'cancelaDescuentoMercado',
        params: {
          par_local: desc.id_local,
          par_axoi,
          par_mesi,
          par_axof,
          par_mesf,
          par_porc: desc.porcentaje,
          par_autoriza: desc.autoriza
        }
      });
      if (res.data.success) {
        this.mensaje = 'Descuento cancelado correctamente.';
        await this.buscarLocal();
      } else {
        this.mensaje = res.data.message || 'Error al cancelar descuento.';
      }
    },
    formatDate(dt) {
      if (!dt) return '';
      return dt.split('T')[0];
    }
  }
}
</script>

<style scoped>
.desc-derechos-merc-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.form-row {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  align-items: center;
  margin-bottom: 1rem;
}
.table {
  width: 100%;
  border-collapse: collapse;
}
.table th, .table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.alert {
  color: #b00;
  margin-top: 1rem;
}
</style>
